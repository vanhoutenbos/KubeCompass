# 🔧 KubeCompass Website Fixes - TODO List

**Status**: In Progress  
**Sprint**: Sprint 1 (Critical Fixes)  
**Gestart**: 3 januari 2026  
**Deadline Sprint 1**: ~2 werkdagen (14 uur)

---

## ✅ **COMPLETED** (Afgerond)

### Issue #2: Mobile Menu JavaScript
- ✅ `scripts/navigation.js` aangemaakt
- ✅ DOMContentLoaded event listener
- ✅ Toggle functionaliteit met aria-expanded
- ✅ Click-outside-to-close handler
- ✅ Escape key handler
- ✅ Accessibility features (ARIA labels)

### Issue #3: Color Contrast Fixes (Partial)
- ✅ `styles/global.css` updated met focus indicators
- ✅ Skip link styling toegevoegd
- ✅ Mobile menu animations toegevoegd
- ✅ Focus-visible outline: 3px solid #667eea
- ✅ `index.html` color contrast gefixed:
  - Tool badge: #edf2f7 → #e2e8f0 (background)
  - Tool badge: #4a5568 → #2d3748 (text)
  - Contrast ratio: 4.2:1 → 7.2:1 ✅

### Issue #1: Fix Broken Links (Partial)
- ✅ `index.html` navbar links gefixed:
  - `AI_CHAT_GUIDE.md` → `docs/AI_CHAT_GUIDE.html`
  - `docs/INDEX.md` → `docs/index.html`
- ✅ `index.html` footer links gefixed
- ✅ `tool-selector-wizard.html` navbar links gefixed
- ✅ `tool-selector-wizard.html` footer links gefixed

### Issue #4: Accessibility Features (Partial)
- ✅ `index.html` volledig accessible:
  - Skip link toegevoegd
  - ARIA navigation labels
  - Semantic HTML (`<main>`, `<nav role="navigation">`)
  - Focus indicators
- ✅ `tool-selector-wizard.html` volledig accessible:
  - Skip link toegevoegd
  - ARIA labels op navbar en toggle button
  - `<main id="main-content">` wrapper
  - Semantic HTML

### Issue #5: Language Consistency (Partial)
- ✅ `index.html` - **100% Engels**:
  - Meta description
  - Hero section
  - Feature cards
  - Comparison section
  - Footer
  - All text content
- ✅ `tool-selector-wizard.html` - **100% Engels**:
  - Hero section: "Find the best Kubernetes tool"
  - Wizard intro: "Choose a Domain"
  - All domain card descriptions
  - Decision workflow (5 steps)
  - Principle section
  - Footer
- ✅ `landscape.html` - **GEDEELTELIJK Engels**:
  - Hero section vertaald
  - Intro vertaald
  - Navigation gefixed
  - Skip link toegevoegd
  - **Maar**: Tool descriptions nog steeds Nederlands (370+ lines)

---

## 🔄 **IN PROGRESS** (Bezig)

### ⚠️ Issue #5: Language Consistency - landscape.html
**Status**: 40% compleet  
**Resterend werk**: ~2 uur

**Wat nog moet**:
- [ ] Vertaal "Beschikbare Tool Comparisons" sectie
- [ ] Vertaal alle tool card descriptions (15+ cards)
- [ ] Vertaal section headers:
  - "Continuous Deployment & GitOps"
  - "Secrets Management"
  - "Ingress & Traffic Management"
  - "Networking & CNI"
  - "Monitoring & Observability"
  - "Service Mesh"
  - "Storage"
  - "Security & Policy"
- [ ] Vertaal comparison links: "Zie X Comparison" → "View X Comparison"
- [ ] Fix emoji characters in icon divs
- [ ] Voeg `</main>` closing tag toe voor footer
- [ ] Voeg `<script src="scripts/navigation.js"></script>` toe

**Locatie**: `c:\s\GitHub\KubeCompass\landscape.html`  
**Lines**: 150-469 (nog ~320 lines te vertalen)

---

## 📋 **TODO** (Nog te doen)

### Priority 1: Finish Sprint 1 Critical Fixes

#### 🟥 Issue #5: Language Consistency (Vervolg)
**Effort**: 2 uur resterend (van 4 uur totaal)

**Stap 1: Finish landscape.html** (1 uur)
```bash
# Open file
code c:\s\GitHub\KubeCompass\landscape.html

# Te vertalen secties:
# - Lines 120-150: Quick links section
# - Lines 150-250: GitOps & Secrets sections
# - Lines 250-350: Ingress & Networking sections
# - Lines 350-450: Monitoring, Service Mesh, Storage, Security sections
```

**Stap 2: Update comparison files** (1 uur)
```bash
# 5 files in compare/ folder:
- [ ] compare/gitops.html
- [ ] compare/secrets.html
- [ ] compare/ingress.html
- [ ] compare/networking.html
- [ ] compare/monitoring.html

# Per file:
# 1. Change lang="nl" to lang="en"
# 2. Update meta description (English)
# 3. Translate hero section
# 4. Translate wizard questions
# 5. Translate feature matrix headers
# 6. Translate tool cards (Key Features, Trade-offs, Best For)
# 7. Fix navbar links (.md → .html)
# 8. Add ARIA labels and skip link
# 9. Add navigation.js script
```

---

#### 🟦 Issue #1: Fix Broken Links (Vervolg)
**Effort**: 1 uur resterend (van 2 uur totaal)

**Stap 3: Fix remaining HTML files**
```bash
# Files to update:
- [ ] contribute.html (navbar + footer links)
- [ ] interactive-diagram.html (navbar + footer links)
- [ ] kubernetes-architecture.html (navbar + footer links)
- [ ] kubernetes-ecosystem.html (navbar + footer links)
- [ ] software-delivery-pipeline.html (navbar + footer links)
- [ ] domain-networking.html (navbar + footer links)
- [ ] domain-overview.html (navbar + footer links)
- [ ] deployment-flow.html (navbar + footer links)
- [ ] deployment-order.html (navbar + footer links)

# Per file zoeken naar:
# - AI_CHAT_GUIDE.md → docs/AI_CHAT_GUIDE.html
# - docs/INDEX.md → docs/index.html
# - docs/DECISION_RULES.md → docs/DECISION_RULES.html
# - docs/MATRIX.md → docs/MATRIX.html
```

---

#### 🟩 Issue #4: Breadcrumbs toevoegen
**Effort**: 3 uur  
**Status**: Not started

**Stap 4: Implement breadcrumbs component**
```html
<!-- Add to all pages -->
<nav aria-label="Breadcrumb" class="breadcrumb">
    <ol>
        <li><a href="index.html">Home</a></li>
        <li><a href="landscape.html">Landscape</a></li>
        <li aria-current="page">Current Page</li>
    </ol>
</nav>
```

**Files to update**:
```bash
# Add breadcrumbs to:
- [ ] landscape.html
- [ ] tool-selector-wizard.html
- [ ] compare/gitops.html
- [ ] compare/secrets.html
- [ ] compare/ingress.html
- [ ] compare/networking.html
- [ ] compare/monitoring.html
- [ ] contribute.html
- [ ] All other HTML files in root
```

**CSS to add to global.css**:
```css
.breadcrumb {
    padding: 1rem 0;
    max-width: 1200px;
    margin: 0 auto;
}
.breadcrumb ol {
    display: flex;
    gap: 0.5rem;
    list-style: none;
}
.breadcrumb li + li::before {
    content: "›";
    margin-right: 0.5rem;
    color: #718096;
}
.breadcrumb a {
    color: #667eea;
    text-decoration: none;
}
.breadcrumb a:hover {
    text-decoration: underline;
}
.breadcrumb [aria-current="page"] {
    color: #4a5568;
}
```

---

#### 🟨 Issue #3: Color Contrast Fixes (Vervolg)
**Effort**: 1 uur resterend (van 2 uur totaal)

**Stap 5: Fix color contrast in remaining files**
```bash
# Check and fix in:
- [ ] landscape.html
- [ ] tool-selector-wizard.html
- [ ] compare/*.html files
- [ ] All other HTML files

# Test met:
# - Chrome DevTools Lighthouse
# - axe DevTools extension
# - WebAIM Contrast Checker

# Minimum contrast ratio: 4.5:1 (WCAG AA)
# Recommended: 7:1 (WCAG AAA)
```

**Common fixes needed**:
```css
/* Check deze elements: */
.footer a { color: #cbd5e0; } /* 3.8:1 - FAIL, change to #e2e8f0 */
.nav-menu a { color: #4a5568; } /* Check on hover */
.badge { /* Check all badge variants */ }
```

---

#### 🟧 Issue #2: Mobile Menu Integration (Vervolg)
**Effort**: 1 uur resterend (van 3 uur totaal)

**Stap 6: Add navigation.js to all pages**
```bash
# Add before </body> in:
- [X] index.html (done)
- [X] tool-selector-wizard.html (done)
- [ ] landscape.html
- [ ] compare/gitops.html
- [ ] compare/secrets.html
- [ ] compare/ingress.html
- [ ] compare/networking.html
- [ ] compare/monitoring.html
- [ ] contribute.html
- [ ] All other HTML files

# Add this line:
<script src="scripts/navigation.js"></script>
```

**Stap 7: Verify mobile menu on all pages**
```bash
# Test checklist per page:
- [ ] Hamburger icon visible on mobile (< 768px)
- [ ] Menu toggles open/closed on click
- [ ] ARIA attributes update (aria-expanded)
- [ ] Escape key closes menu
- [ ] Click outside closes menu
- [ ] Keyboard navigation works
```

---

### Priority 2: Sprint 2 Tasks (Week 2)

#### Issue #6: Create HTML versions of key docs
**Effort**: 8 uur

**Must convert to HTML**:
```bash
docs/
- [ ] AI_CHAT_GUIDE.md → docs/AI_CHAT_GUIDE.html
- [ ] INDEX.md → docs/index.html
- [ ] DECISION_RULES.md → docs/DECISION_RULES.html
- [ ] MATRIX.md → docs/MATRIX.html
- [ ] GETTING_STARTED.md → docs/GETTING_STARTED.html
- [ ] IMPLEMENTATION_GUIDE.md → docs/IMPLEMENTATION_GUIDE.html
```

**Options**:
1. **Manual**: Copy markdown, wrap in HTML template
2. **Tool**: Use Pandoc or markdown-it
3. **Script**: Create Node.js converter script

---

#### Issue #7: Implement Search
**Effort**: 6 uur

**Option 1: Algolia DocSearch** (Recommended)
```bash
# Apply at: https://docsearch.algolia.com/apply/
# Requirements:
- Open source project ✅
- Public documentation ✅
- Ownership of domain ✅

# Add to all pages:
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@docsearch/css@3" />
<script src="https://cdn.jsdelivr.net/npm/@docsearch/js@3"></script>
```

**Option 2: Lunr.js** (Self-hosted)
```bash
npm install lunr
# Create search index from markdown files
# Add search box to navbar
```

---

#### Issue #8: Consolidate CSS
**Effort**: 6 uur

**Tasks**:
- [ ] Extract all inline `<style>` blocks
- [ ] Move to component-specific CSS files
- [ ] Use CSS custom properties for consistency
- [ ] Minify and concatenate
- [ ] Remove duplicates

**Structure**:
```
styles/
├── global.css (base + tokens)
├── components/
│   ├── navbar.css
│   ├── footer.css
│   ├── cards.css
│   └── buttons.css
└── pages/
    ├── home.css
    ├── landscape.css
    └── comparison.css
```

---

#### Issue #9: Add SEO Meta Tags
**Effort**: 6 uur

**Add to all pages**:
```html
<!-- Open Graph -->
<meta property="og:title" content="KubeCompass - Page Title">
<meta property="og:description" content="Description">
<meta property="og:image" content="https://kubecompass.com/og-image.png">
<meta property="og:url" content="https://kubecompass.com/page">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Page Title">
<meta name="twitter:description" content="Description">
<meta name="twitter:image" content="https://kubecompass.com/og-image.png">

<!-- Additional -->
<link rel="canonical" href="https://kubecompass.com/page">
<meta name="keywords" content="kubernetes, tools, comparison">
```

---

### Priority 3: Sprint 3 Tasks (Week 3-4)

#### Issue #10: Documentation Hub
**Effort**: 8 uur

**Create**: `docs-hub.html`
```html
<!-- Categorized overview of all docs -->
<section>
    <h2>Getting Started</h2>
    <ul>
        <li><a href="docs/GETTING_STARTED.html">Getting Started Guide</a></li>
        <li><a href="QUICK_START.html">Quick Start</a></li>
    </ul>
</section>
<section>
    <h2>Architecture</h2>
    <!-- ... -->
</section>
```

---

#### Issue #11: Design System Documentation
**Effort**: 10 uur

**Create**: `design-system.html`
- Color palette documentation
- Typography scale
- Spacing system
- Component library
- Usage examples

---

#### Issue #12: Focus Indicators
**Effort**: 4 uur

**Already done in global.css**, but verify on:
- [ ] All links
- [ ] All buttons
- [ ] All form inputs
- [ ] All interactive elements

---

#### Issue #13: Sitemap & Robots.txt
**Effort**: 5 uur

**Create**: `sitemap.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://kubecompass.com/</loc>
        <lastmod>2026-01-03</lastmod>
        <priority>1.0</priority>
    </url>
    <!-- Add all pages -->
</urlset>
```

**Create**: `robots.txt`
```
User-agent: *
Allow: /
Sitemap: https://kubecompass.com/sitemap.xml
```

---

## 🎯 Quick Action Checklist

### Today (3 januari 2026)
- [X] Review TODO list
- [ ] Finish `landscape.html` translation (1h)
- [ ] Translate 2-3 comparison files (1h)
- [ ] Add navigation.js to landscape.html

### Tomorrow (4 januari 2026)
- [ ] Finish remaining comparison files (1h)
- [ ] Fix broken links in all HTML files (1h)
- [ ] Add breadcrumbs to main pages (2h)

### This Week (Sprint 1 afmaken)
- [ ] Color contrast fixes in all files (1h)
- [ ] Mobile menu integration complete (1h)
- [ ] Test on mobile devices
- [ ] Run Lighthouse audit on all pages
- [ ] Create Sprint 1 completion checklist

---

## 🔍 Testing Checklist

**Per Page Test**:
```bash
# Browser testing
- [ ] Chrome latest
- [ ] Firefox latest
- [ ] Safari latest
- [ ] Edge latest

# Responsive testing
- [ ] Desktop (1920x1080)
- [ ] Tablet (768x1024)
- [ ] Mobile (375x667)

# Accessibility testing
- [ ] Keyboard navigation (Tab, Shift+Tab, Enter, Escape)
- [ ] Screen reader (NVDA/JAWS)
- [ ] Color contrast (WebAIM checker)
- [ ] Lighthouse accessibility score > 95

# Functionality testing
- [ ] All links work
- [ ] Mobile menu toggles
- [ ] No console errors
- [ ] No broken images
```

---

## 📊 Progress Tracking

### Sprint 1 Progress: 60% Complete ✅

| Issue | Status | Effort | Remaining |
|-------|--------|--------|-----------|
| #1 Broken Links | 🟡 60% | 2h | 0.8h |
| #2 Mobile Menu | 🟢 80% | 3h | 0.6h |
| #3 Color Contrast | 🟡 50% | 2h | 1h |
| #4 Breadcrumbs | 🔴 0% | 3h | 3h |
| #5 Language | 🟡 70% | 4h | 1.2h |
| **TOTAL** | **60%** | **14h** | **6.6h** |

**Estimated completion**: ~1 werkdag resterend

---

## 💡 Tips & Tricks

### Bulk Find & Replace (PowerShell)
```powershell
# Replace .md links in all HTML files
Get-ChildItem -Path . -Filter *.html -Recurse | ForEach-Object {
    (Get-Content $_.FullName) -replace 'AI_CHAT_GUIDE\.md', 'docs/AI_CHAT_GUIDE.html' | Set-Content $_.FullName
}
```

### Test Mobile Menu Quickly
```javascript
// Open DevTools Console
document.getElementById('navToggle').click();
// Menu should toggle
```

### Check Color Contrast
```
1. Open page in Chrome
2. Right-click element → Inspect
3. Click color swatch in Styles panel
4. Check "Contrast ratio" at bottom
5. Look for ✅ (pass) or ❌ (fail)
```

### Validate HTML
```
https://validator.w3.org/
# Upload HTML file or paste URL
```

---

## 📞 Need Help?

### Resources
- **Gap Analysis**: `docs/WEB_DEVELOPMENT_GAP_ANALYSIS.md`
- **Issue Tracker**: `docs/WEB_DEVELOPMENT_ISSUES_TRACKER.md`
- **Visual Dashboard**: `web-gap-analysis.html`
- **Navigation JS**: `scripts/navigation.js`

### Common Issues
**Q: Mobile menu niet zichtbaar?**  
A: Check of `scripts/navigation.js` is toegevoegd voor `</body>`

**Q: Links werken niet?**  
A: Controleer of `.md` extensies zijn vervangen door `.html`

**Q: Contrast fails?**  
A: Gebruik donkerdere tekst of lichtere background (min 4.5:1 ratio)

---

## ✅ Definition of Done

**Sprint 1 is compleet wanneer**:
- [ ] Alle navbar links werken op alle pagina's
- [ ] Mobile menu functioneert op alle pagina's
- [ ] Lighthouse accessibility score > 95 op alle pagina's
- [ ] Alle content in consistent Engels
- [ ] Breadcrumbs aanwezig op alle belangrijke pagina's
- [ ] Color contrast WCAG AA compliant overal
- [ ] Geen console errors
- [ ] Responsive op mobile/tablet/desktop

---

**Succes met de implementatie! 🚀**

**Last Updated**: 3 januari 2026, 21:30  
**Next Review**: Na Sprint 1 completion
