# Web Development Issues & Tasks Tracker
**KubeCompass Website Improvements**

**Gegenereerd**: 3 januari 2026  
**Basis**: Web Development Gap Analysis

> **Gebruik**: Deze file bevat actionable GitHub Issues ready-to-copy

---

## 🔴 CRITICAL (Sprint 1 - Week 1)

### Issue #1: Fix Broken Navigation Links to Markdown Files
**Priority**: P0 - Critical  
**Effort**: 2 hours  
**Labels**: `bug`, `critical`, `navigation`

**Problem**:
Navigation links to `.md` files don't work in browsers, causing 404 errors or download prompts.

**Affected files**:
- `index.html` line 100: `<a href="AI_CHAT_GUIDE.md">`
- `index.html` line 101: `<a href="docs/INDEX.md">`
- `tool-selector-wizard.html` line 74: `<a href="AI_CHAT_GUIDE.md">`
- `landscape.html` similar issues

**Expected behavior**:
Links should navigate to HTML pages or properly rendered Markdown.

**Solutions**:
1. Create HTML versions: `ai-chat-guide.html`, `docs/index.html`
2. Use GitHub Pages Markdown rendering (remove `.md` extension)
3. Implement server-side Markdown rendering

**Acceptance criteria**:
- [ ] All navbar links work without 404s
- [ ] No download prompts for `.md` files
- [ ] Consistent navigation across all pages

---

### Issue #2: Implement Mobile Menu Toggle
**Priority**: P0 - Critical  
**Effort**: 3 hours  
**Labels**: `bug`, `critical`, `responsive`, `javascript`

**Problem**:
Mobile menu button exists but doesn't work - no JavaScript implementation.

**Affected files**:
- All HTML files with `.nav-toggle` button
- No corresponding JavaScript

**Current code**:
```html
<button class="nav-toggle" id="navToggle">
    <span></span><span></span><span></span>
</button>
<ul class="nav-menu" id="navMenu">...</ul>
<!-- Missing: JavaScript to toggle menu -->
```

**Expected behavior**:
Clicking hamburger menu on mobile should show/hide navigation.

**Solution**:
```javascript
// Add to all pages or scripts/navigation.js
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.getElementById('navMenu');
    
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            navToggle.classList.toggle('active');
        });
    }
});
```

**CSS needed**:
```css
@media (max-width: 768px) {
    .nav-menu {
        display: none;
        flex-direction: column;
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: white;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    
    .nav-menu.active {
        display: flex;
    }
}
```

**Acceptance criteria**:
- [ ] Mobile menu opens on click
- [ ] Menu closes when clicking outside
- [ ] Works on all pages
- [ ] Smooth animation
- [ ] Tested on iOS Safari and Android Chrome

---

### Issue #3: Fix Color Contrast for WCAG Compliance
**Priority**: P0 - Critical (Legal requirement EU Accessibility Act 2025)  
**Effort**: 2 hours  
**Labels**: `a11y`, `critical`, `css`

**Problem**:
Multiple UI elements fail WCAG AA contrast requirements (4.5:1 minimum).

**Violations found**:
```css
/* index.html - Tool badges */
.tool-badge {
    background: #edf2f7;
    color: #4a5568;  /* Contrast: 4.2:1 - FAIL */
}

/* Footer links */
.footer-column a {
    color: #cbd5e0;  /* On #2d3748 - Contrast: 3.8:1 - FAIL */
}

/* Hero subtitle */
.hero-subtitle {
    opacity: 0.95;
    color: white;  /* On gradient bg - varies */
}
```

**Solution**:
```css
/* Fix tool badges */
.tool-badge {
    background: #e2e8f0;
    color: #2d3748;  /* Contrast: 7.2:1 - PASS */
}

/* Fix footer links */
.footer-column a {
    color: #e2e8f0;  /* Contrast: 8.1:1 - PASS */
}

/* Fix hero subtitle */
.hero-subtitle {
    color: white;
    text-shadow: 0 2px 4px rgba(0,0,0,0.3);  /* Improve readability */
}
```

**Testing**:
- Use [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Run axe DevTools
- Test with Chrome Lighthouse

**Acceptance criteria**:
- [ ] All text meets WCAG AA (4.5:1)
- [ ] Large text meets WCAG AA (3:1)
- [ ] axe DevTools shows 0 contrast issues
- [ ] Lighthouse accessibility score > 95

---

### Issue #4: Add Breadcrumb Navigation to All Pages
**Priority**: P1 - High  
**Effort**: 3 hours  
**Labels**: `enhancement`, `navigation`, `ux`

**Problem**:
Only `compare/gitops.html` has breadcrumbs. Other pages lack clear location indicators.

**Affected files**:
- `compare/secrets.html`
- `compare/ingress.html`
- `compare/monitoring.html`
- `compare/networking.html`
- `landscape.html`
- `tool-selector-wizard.html`

**Implementation**:
```html
<!-- Add after navbar on every page -->
<div class="breadcrumb">
    <a href="../index.html">Home</a> 
    <span class="separator">/</span>
    <a href="../landscape.html">Landscape</a>
    <span class="separator">/</span>
    <span class="current">Secrets Management</span>
</div>
```

**CSS**:
```css
.breadcrumb {
    padding: 1rem 0;
    font-size: 0.9rem;
}

.breadcrumb a {
    color: #667eea;
    text-decoration: none;
}

.breadcrumb a:hover {
    text-decoration: underline;
}

.breadcrumb .separator {
    color: #a0aec0;
    margin: 0 0.5rem;
}

.breadcrumb .current {
    color: #4a5568;
}
```

**Acceptance criteria**:
- [ ] All pages have breadcrumbs
- [ ] Links work correctly
- [ ] Reflects actual site hierarchy
- [ ] Responsive on mobile

---

### Issue #5: Fix Language Consistency (EN vs NL)
**Priority**: P1 - High  
**Effort**: 4 hours  
**Labels**: `content`, `i18n`, `ux`

**Problem**:
Inconsistent mixing of English and Dutch throughout the site.

**Examples**:
- `index.html`: "Domain Guides" (EN) → "In-depth domain analysis met praktisch tool advies" (NL mix)
- `tool-selector-wizard.html`: `lang="nl"` but mixed content
- `landscape.html`: "Kubernetes Landscape" (EN) → "categorieën" (NL)

**Decision needed**:
**Recommendation**: Choose English for primary language

**Rationale**:
- ✅ Technical audience is international
- ✅ Kubernetes ecosystem is English-dominated
- ✅ Better SEO reach
- ✅ Most documentation already in English
- ❌ Dutch audience is secondary (can add i18n later)

**Action items**:
1. Update `lang` attribute: `<html lang="en">`
2. Translate Dutch strings to English:
   - "Kies Een Domain" → "Choose a Domain"
   - "categorieën" → "categories"
   - "Vergelijkingen" → "Comparisons"
3. Update meta descriptions
4. Keep README.md bilingual (community preference)

**Optional future enhancement**:
Add language selector for Dutch translation:
```html
<div class="language-selector">
    <button onclick="setLanguage('en')" class="active">EN</button>
    <button onclick="setLanguage('nl')">NL</button>
</div>
```

**Acceptance criteria**:
- [ ] All HTML pages use English consistently
- [ ] `lang` attributes are correct
- [ ] No random Dutch words in English text
- [ ] Documentation mentions language choice

---

## 🟡 HIGH PRIORITY (Sprint 2 - Week 2)

### Issue #6: Create HTML Versions of Key Markdown Files
**Priority**: P1 - High  
**Effort**: 8 hours  
**Labels**: `content`, `documentation`, `html`

**Problem**:
Important documented features are inaccessible because they only exist as `.md` files.

**Required HTML pages**:
1. `ai-chat-guide.html` (from `AI_CHAT_GUIDE.md`)
2. `docs/index.html` (from `docs/INDEX.md`)
3. `getting-started.html` (from `docs/GETTING_STARTED.md`)
4. `contributing.html` (from `CONTRIBUTING.md`)

**Approach**:
Option 1: Manual HTML conversion (quick)
Option 2: Markdown renderer (scalable)
Option 3: Static site generator (recommended long-term)

**For Sprint 2** (quick solution):
Use Markdown-to-HTML converter:
- Marked.js for client-side rendering
- Or Pandoc for build-time conversion

**Template structure**:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>AI Chat Guide - KubeCompass</title>
    <link rel="stylesheet" href="styles/global.css">
</head>
<body>
    <!-- Include navbar component -->
    <nav class="navbar">...</nav>
    
    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="index.html">Home</a> / <span>AI Chat Guide</span>
    </div>
    
    <!-- Content -->
    <main class="doc-content">
        <!-- Converted Markdown content -->
    </main>
    
    <!-- Include footer component -->
    <footer class="footer">...</footer>
</body>
</html>
```

**Acceptance criteria**:
- [ ] All 4 HTML pages created
- [ ] Content matches source Markdown
- [ ] Consistent styling with rest of site
- [ ] Linked from navbar/homepage
- [ ] Responsive layout
- [ ] Code blocks have syntax highlighting

---

### Issue #7: Implement Site-wide Search
**Priority**: P1 - High  
**Effort**: 6 hours  
**Labels**: `feature`, `search`, `ux`

**Problem**:
With 18 domains and 400+ documents, content is hard to discover without search.

**Recommended solution**: **Algolia DocSearch** (free for open source)

**Implementation**:
1. Apply for Algolia DocSearch: https://docsearch.algolia.com/apply/
2. Add search to navbar:
```html
<div id="docsearch"></div>

<script src="https://cdn.jsdelivr.net/npm/@docsearch/js@3"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@docsearch/css@3">

<script>
docsearch({
  appId: 'YOUR_APP_ID',
  apiKey: 'YOUR_API_KEY',
  indexName: 'kubecompass',
  container: '#docsearch'
});
</script>
```

**Alternative** (if Algolia not approved):
Client-side search with Lunr.js:
```javascript
// Build search index
const idx = lunr(function () {
  this.ref('id')
  this.field('title')
  this.field('content')
  
  documents.forEach(doc => this.add(doc))
})

// Search
const results = idx.search(query)
```

**Acceptance criteria**:
- [ ] Search box in navbar on all pages
- [ ] Searches through all documentation
- [ ] Shows relevant results
- [ ] Keyboard shortcut (Cmd/Ctrl + K)
- [ ] Mobile-friendly

---

### Issue #8: Consolidate Inline CSS to global.css
**Priority**: P1 - High  
**Effort**: 8 hours  
**Labels**: `css`, `performance`, `maintainability`

**Problem**:
Massive code duplication with inline `<style>` tags on every page.

**Statistics**:
- `index.html`: 217 lines of inline CSS
- `compare/gitops.html`: 150+ lines
- `tool-selector-wizard.html`: 160+ lines
- Total duplication: ~70% overlap

**Impact**:
- Larger page sizes
- Harder to maintain
- No caching benefits
- Style inconsistencies

**Solution**:
1. Audit all inline styles
2. Extract common patterns to `global.css`
3. Create page-specific CSS files only when needed
4. Use CSS custom properties for theming

**File structure**:
```
styles/
├── global.css (existing)
├── components.css (new - navbar, footer, cards)
├── pages/
│   ├── home.css
│   ├── comparison.css
│   └── landscape.css
└── utilities.css (new - helper classes)
```

**Process**:
```bash
# 1. Extract common styles
# Find repeated CSS patterns
grep -r "\.navbar" *.html | sort | uniq -c

# 2. Move to global.css
# 3. Replace inline styles with class references
# 4. Test each page
```

**Acceptance criteria**:
- [ ] No inline `<style>` tags (except critical CSS)
- [ ] All common styles in global.css
- [ ] Page-specific styles in separate files
- [ ] Total CSS size reduced by 40%+
- [ ] All pages render identically

---

### Issue #9: Add SEO Meta Tags to All Pages
**Priority**: P1 - High  
**Effort**: 4 hours  
**Labels**: `seo`, `meta`, `enhancement`

**Problem**:
Only `compare/gitops.html` has proper meta description. Other pages missing SEO essentials.

**Required on EVERY page**:
```html
<head>
    <!-- Basic SEO -->
    <meta name="description" content="Page-specific description (150-160 chars)">
    <meta name="keywords" content="kubernetes, gitops, argocd, flux">
    
    <!-- Open Graph (Social sharing) -->
    <meta property="og:title" content="Page Title - KubeCompass">
    <meta property="og:description" content="Page description">
    <meta property="og:image" content="https://kubecompass.dev/og-image.png">
    <meta property="og:url" content="https://kubecompass.dev/page">
    <meta property="og:type" content="website">
    
    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="Page Title">
    <meta name="twitter:description" content="Page description">
    <meta name="twitter:image" content="https://kubecompass.dev/og-image.png">
    
    <!-- Canonical URL -->
    <link rel="canonical" href="https://kubecompass.dev/page">
</head>
```

**Page-specific descriptions needed**:
- **index.html**: "Opinionated Kubernetes tool recommendations. Production-ready guidance without vendor bias. Compare 18 domains with hands-on testing."
- **landscape.html**: "Complete Kubernetes ecosystem overview. Explore tools across CNI, GitOps, secrets management, observability, and more."
- **tool-selector-wizard.html**: "Interactive Kubernetes tool selector. Answer questions about scale and priorities to get personalized recommendations."
- **compare/gitops.html**: Already done ✅
- **compare/secrets.html**: "Kubernetes secrets management comparison. External Secrets Operator vs Sealed Secrets vs SOPS with production examples."
- **compare/ingress.html**: "Ingress controller comparison. NGINX vs Traefik vs Istio for Kubernetes traffic routing."
- **compare/networking.html**: "CNI comparison. Cilium vs Calico vs Flannel for Kubernetes networking."
- **compare/monitoring.html**: "Kubernetes monitoring comparison. Prometheus vs Datadog vs New Relic for observability."

**Additional SEO tasks**:
- [ ] Create `sitemap.xml`
- [ ] Create `robots.txt`
- [ ] Add structured data (Schema.org)

**Acceptance criteria**:
- [ ] All pages have unique meta descriptions
- [ ] OG tags on all pages
- [ ] Images optimized for social sharing (1200x630px)
- [ ] Google Search Console validation passes

---

## 🟢 MEDIUM PRIORITY (Sprint 3 - Week 3-4)

### Issue #10: Create Documentation Hub Landing Page
**Priority**: P2 - Medium  
**Effort**: 6 hours  
**Labels**: `feature`, `documentation`, `ux`

**Problem**:
400+ documents but no central discovery page beyond `docs/INDEX.md`.

**Solution**: Create `documentation.html`

**Proposed structure**:
```
📚 Documentation Hub
├── 🚀 Getting Started
│   ├── Quick Start (5 min)
│   ├── Installation Guide
│   ├── First Steps
│   └── Docker Setup
├── 🧭 Tool Guides (18 domains)
│   ├── GitOps (ArgoCD vs Flux)
│   ├── Secrets Management
│   ├── Networking (CNI)
│   ├── Ingress Controllers
│   └── Monitoring & Observability
├── 📋 Case Studies
│   ├── Dutch Webshop Migration
│   ├── Enterprise Multi-tenant
│   └── Edge Computing Setup
├── 🏗️ Implementation
│   ├── Testing Methodology
│   ├── Production Readiness
│   └── Kind Cluster Setup
└── 🤝 Contributing
    ├── How to Contribute
    ├── Documentation Standards
    └── Testing Tools
```

**Features**:
- Card-based layout
- Search integration
- Progress indicators (✅ Complete, 🚧 In Progress, 📝 Planned)
- Estimated reading times
- Tag filtering (beginner, advanced, hands-on)

**Acceptance criteria**:
- [ ] All major docs linked
- [ ] Logical categorization
- [ ] Progress tracking visible
- [ ] Mobile responsive
- [ ] Linked from navbar

---

### Issue #11: Implement Design System / Component Library
**Priority**: P2 - Medium  
**Effort**: 16 hours  
**Labels**: `design`, `components`, `css`

**Problem**:
3+ different card styles, inconsistent buttons, no reusable components.

**Solution**: Create atomic design system.

**Structure**:
```
design-system/
├── tokens.css (variables)
├── atoms/
│   ├── button.css
│   ├── badge.css
│   ├── input.css
│   └── link.css
├── molecules/
│   ├── card.css
│   ├── navbar.css
│   └── breadcrumb.css
└── organisms/
    ├── hero.css
    ├── comparison-table.css
    └── footer.css
```

**Tokens** (`tokens.css`):
```css
:root {
    /* Colors */
    --color-primary: #667eea;
    --color-primary-dark: #764ba2;
    --color-success: #48bb78;
    --color-danger: #e53e3e;
    --color-warning: #ed8936;
    
    /* Typography */
    --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --font-mono: "SF Mono", Consolas, monospace;
    --font-size-sm: 0.875rem;
    --font-size-base: 1rem;
    --font-size-lg: 1.125rem;
    --font-size-xl: 1.5rem;
    
    /* Spacing */
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 2rem;
    --spacing-xl: 4rem;
    
    /* Shadows */
    --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
    --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
    --shadow-lg: 0 10px 30px rgba(0,0,0,0.15);
    
    /* Borders */
    --radius-sm: 4px;
    --radius-md: 8px;
    --radius-lg: 12px;
}
```

**Components** (example button):
```css
/* atoms/button.css */
.btn {
    display: inline-block;
    padding: var(--spacing-sm) var(--spacing-md);
    border-radius: var(--radius-md);
    font-weight: 600;
    text-decoration: none;
    transition: all 0.3s;
    cursor: pointer;
    border: none;
}

.btn-primary {
    background: var(--color-primary);
    color: white;
}

.btn-primary:hover {
    background: var(--color-primary-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.btn-secondary {
    background: transparent;
    color: var(--color-primary);
    border: 2px solid var(--color-primary);
}
```

**Documentation**: Create Storybook or simple showcase page.

**Acceptance criteria**:
- [ ] All components documented
- [ ] Consistent usage across site
- [ ] Tokens used everywhere
- [ ] No hardcoded colors/spacing
- [ ] Design system page created

---

### Issue #12: Add Focus Indicators for Keyboard Navigation
**Priority**: P2 - Medium (a11y requirement)  
**Effort**: 3 hours  
**Labels**: `a11y`, `css`, `ux`

**Problem**:
No visible focus indicators for keyboard navigation.

**Solution**:
```css
/* Add to global.css */

/* Default focus style */
*:focus {
    outline: 3px solid var(--color-primary);
    outline-offset: 2px;
}

/* Specific focus styles */
a:focus,
button:focus {
    outline: 3px solid var(--color-primary);
    outline-offset: 2px;
}

/* Don't show focus for mouse clicks */
*:focus:not(:focus-visible) {
    outline: none;
}

*:focus-visible {
    outline: 3px solid var(--color-primary);
    outline-offset: 2px;
}

/* Cards with focus */
.comparison-card:focus {
    outline: 3px solid var(--color-primary);
    box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
}

/* Button focus states */
.btn:focus-visible {
    outline: 3px solid var(--color-primary);
    outline-offset: 4px;
}

/* Skip link for screen readers */
.skip-link {
    position: absolute;
    top: -40px;
    left: 0;
    background: var(--color-primary);
    color: white;
    padding: 8px;
    z-index: 100;
}

.skip-link:focus {
    top: 0;
}
```

**Add skip link to all pages**:
```html
<body>
    <a href="#main-content" class="skip-link">Skip to main content</a>
    <!-- ... rest of page -->
    <main id="main-content">...</main>
</body>
```

**Testing**:
- Tab through entire page
- Ensure all interactive elements have focus
- Test with keyboard only (no mouse)
- Verify color contrast of focus indicators

**Acceptance criteria**:
- [ ] All interactive elements show focus
- [ ] Skip links present on all pages
- [ ] Focus indicators meet WCAG 2.1 Level AA
- [ ] Keyboard navigation works completely

---

### Issue #13: Create sitemap.xml and robots.txt
**Priority**: P2 - Medium  
**Effort**: 2 hours  
**Labels**: `seo`, `infrastructure`

**Files to create**:

**1. `robots.txt`**:
```txt
# robots.txt for KubeCompass
User-agent: *
Allow: /
Disallow: /tests/
Disallow: /scripts/
Disallow: /*.backup$

# Sitemap
Sitemap: https://kubecompass.dev/sitemap.xml
```

**2. `sitemap.xml`**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    
    <url>
        <loc>https://kubecompass.dev/</loc>
        <lastmod>2026-01-03</lastmod>
        <changefreq>weekly</changefreq>
        <priority>1.0</priority>
    </url>
    
    <url>
        <loc>https://kubecompass.dev/landscape.html</loc>
        <lastmod>2026-01-03</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>
    
    <url>
        <loc>https://kubecompass.dev/tool-selector-wizard.html</loc>
        <lastmod>2026-01-03</lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.8</priority>
    </url>
    
    <!-- Comparisons -->
    <url>
        <loc>https://kubecompass.dev/compare/gitops.html</loc>
        <lastmod>2025-12-28</lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.9</priority>
    </url>
    
    <!-- Add all pages -->
    
</urlset>
```

**Automation** (for future):
Generate sitemap automatically from file structure:
```javascript
// scripts/generate-sitemap.js
const fs = require('fs');
const glob = require('glob');

const pages = glob.sync('**/*.html');
const sitemap = generateSitemap(pages);
fs.writeFileSync('sitemap.xml', sitemap);
```

**Acceptance criteria**:
- [ ] robots.txt created
- [ ] sitemap.xml includes all pages
- [ ] Submitted to Google Search Console
- [ ] Bing Webmaster Tools configured
- [ ] Validated with XML validator

---

## 🔵 LOW PRIORITY (Sprint 4+ - Week 5+)

### Issue #14: Implement Analytics (Plausible)
**Priority**: P3 - Low  
**Effort**: 2 hours  
**Labels**: `analytics`, `monitoring`

**Solution**: Use Plausible (privacy-friendly, GDPR compliant)

**Implementation**:
```html
<script defer data-domain="kubecompass.dev" 
        src="https://plausible.io/js/script.js"></script>
```

**Events to track**:
- Tool selector: Tool selected
- Comparisons: "Learn More" clicks
- Export: Markdown/JSON exports
- Search: Search queries

**Acceptance criteria**:
- [ ] Plausible account setup
- [ ] Script on all pages
- [ ] Custom events configured
- [ ] Dashboard shared (if open source)

---

### Issue #15: Add Dark Mode Support
**Priority**: P3 - Low  
**Effort**: 8 hours  
**Labels**: `feature`, `css`, `ux`

**Implementation**:
```css
/* Detect system preference */
@media (prefers-color-scheme: dark) {
    :root {
        --bg-primary: #1a202c;
        --bg-secondary: #2d3748;
        --text-primary: #f7fafc;
        --text-secondary: #e2e8f0;
        /* ... more tokens */
    }
}

/* Manual toggle */
[data-theme="dark"] {
    --bg-primary: #1a202c;
    /* ... */
}
```

**Toggle button**:
```html
<button id="theme-toggle" aria-label="Toggle dark mode">
    <span class="light-icon">🌙</span>
    <span class="dark-icon">☀️</span>
</button>
```

**Acceptance criteria**:
- [ ] Auto-detect system preference
- [ ] Manual toggle works
- [ ] Preference persisted (localStorage)
- [ ] Smooth transition
- [ ] All colors have dark variants

---

### Issue #16: Migrate to Static Site Generator (Docusaurus)
**Priority**: P2 - Medium (Strategic)  
**Effort**: 40 hours  
**Labels**: `infrastructure`, `migration`, `architecture`

**Problem**:
Manual HTML maintenance doesn't scale. Need build system.

**Recommendation**: **Docusaurus v3**

**Benefits**:
- ✅ Built for documentation
- ✅ React-based (interactive components)
- ✅ MDX support (Markdown + JSX)
- ✅ Built-in search (Algolia)
- ✅ Versioning support
- ✅ i18n support (for Dutch later)
- ✅ Dark mode built-in
- ✅ Mobile responsive
- ✅ SEO optimized

**Migration plan**:
```bash
# 1. Setup Docusaurus
npx create-docusaurus@latest kubecompass-site classic

# 2. Structure
site/
├── docs/           # Move all .md files here
├── blog/           # Future blog posts
├── src/
│   ├── components/ # Comparison cards, tool selector
│   ├── pages/      # Custom pages (home, landscape)
│   └── css/        # Global styles
├── static/         # Images, assets
└── docusaurus.config.js

# 3. Config
module.exports = {
  title: 'KubeCompass',
  tagline: 'Production-ready Kubernetes guidance',
  url: 'https://kubecompass.dev',
  baseUrl: '/',
  favicon: 'img/favicon.ico',
  
  themeConfig: {
    navbar: {
      title: 'KubeCompass',
      logo: { src: 'img/logo.svg' },
      items: [
        { to: 'docs/', label: 'Guides', position: 'left' },
        { to: 'landscape', label: 'Landscape', position: 'left' },
        { href: 'https://github.com/vanhoutenbos/KubeCompass', 
          label: 'GitHub', position: 'right' },
      ],
    },
    
    algolia: {
      appId: 'YOUR_APP_ID',
      apiKey: 'YOUR_API_KEY',
      indexName: 'kubecompass',
    },
  },
};

# 4. Migrate content
- Convert HTML to MDX
- Move existing Markdown to docs/
- Create custom React components for comparison tables
- Style with Docusaurus theme

# 5. Deploy
- GitHub Actions for auto-deploy
- Deploy to GitHub Pages / Netlify / Vercel
```

**Phases**:
1. **Phase 1**: Setup & navigation (8h)
2. **Phase 2**: Migrate documentation (12h)
3. **Phase 3**: Custom components (12h)
4. **Phase 4**: Styling & polish (8h)

**Acceptance criteria**:
- [ ] All content migrated
- [ ] Custom components work
- [ ] Search implemented
- [ ] Build & deploy pipeline
- [ ] Old URLs redirect properly
- [ ] Performance improved

---

## 📋 Sprint Planning Summary

### Sprint 1 (Week 1): Critical Fixes
**Goal**: Make site functional
- #1 Fix broken .md links (2h)
- #2 Mobile menu toggle (3h)
- #3 Color contrast fix (2h)
- #4 Breadcrumbs (3h)
- #5 Language consistency (4h)
**Total**: 14 hours

### Sprint 2 (Week 2): Content Accessibility  
**Goal**: Make docs accessible
- #6 Create HTML versions (8h)
- #7 Implement search (6h)
- #8 Consolidate CSS (8h)
- #9 SEO meta tags (4h)
**Total**: 26 hours

### Sprint 3 (Week 3-4): UX Polish
**Goal**: Professional quality
- #10 Documentation hub (6h)
- #11 Design system (16h)
- #12 Focus indicators (3h)
- #13 Sitemap/robots (2h)
**Total**: 27 hours

### Sprint 4+ (Week 5+): Strategic
**Goal**: Long-term scalability
- #14 Analytics (2h)
- #15 Dark mode (8h)
- #16 Docusaurus migration (40h)
**Total**: 50 hours

---

**Grand Total**: ~117 hours (3 weeks fulltime)

**Next Steps**:
1. Create GitHub Project board
2. Assign issues to sprints
3. Tag with appropriate labels
4. Begin Sprint 1

---

**Document Status**: ✅ Ready for implementation  
**Last Updated**: 2026-01-03
