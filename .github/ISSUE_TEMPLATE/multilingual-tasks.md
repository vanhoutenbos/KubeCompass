---
name: Multi-Lingual Support Tasks
about: Track EN/NL translation work for KubeCompass
title: '[i18n] Multi-Lingual Support Implementation'
labels: ['enhancement', 'i18n', 'documentation']
assignees: ''
---

# Multi-Lingual Support - EN/NL Implementation

## Goal
Make KubeCompass fully accessible in both **English (EN)** and **Dutch (NL)** to serve international community while maintaining Dutch roots.

---

## Phase 1: Core Pages (Priority: HIGH)

### Homepage & Navigation
- [ ] **index.html** - Translate hero, features, comparisons, CTA
  - [ ] Hero section (tagline, stats, buttons)
  - [ ] Features section (6 cards)
  - [ ] CTA section
  - [ ] Footer
  - [ ] Add language toggle (EN/NL switcher in navbar)
- [ ] **Navigation menu** - Consistent across all pages
  - [ ] Navbar items
  - [ ] Footer columns

### Interactive Tools
- [ ] **tool-selector-wizard.html** - Full UI translation
  - [ ] Domain cards and descriptions
  - [ ] Filter labels and options
  - [ ] Tool cards (names, descriptions, tags)
  - [ ] Export button text
  - [ ] Decision guidance text
- [ ] **landscape.html** - Domain overview translation
  - [ ] Domain names and descriptions
  - [ ] Category labels
  - [ ] Navigation elements

### Tool Comparisons (5 pages)
- [ ] **compare/gitops.html** - ArgoCD vs Flux
- [ ] **compare/secrets.html** - ESO vs Sealed Secrets vs SOPS
- [ ] **compare/ingress.html** - NGINX vs Traefik vs Istio
- [ ] **compare/networking.html** - Cilium vs Calico vs Flannel
- [ ] **compare/monitoring.html** - Prometheus vs Datadog vs New Relic

Each comparison needs:
- [ ] Decision matrix translation
- [ ] Pro/con lists
- [ ] "Choose X unless Y" rules
- [ ] Implementation notes
- [ ] Code examples comments

---

## Phase 2: Documentation (Priority: MEDIUM)

### Core Framework Docs
- [ ] **README.md** - Keep EN primary, add NL section
  - [ ] Main description
  - [ ] Features list
  - [ ] Quick start guide
  - [ ] Project status
  - [ ] Contributing section
- [ ] **QUICK_START.md** - Duplicate as QUICK_START.nl.md
- [ ] **CONTRIBUTING.md** - Duplicate as CONTRIBUTING.nl.md

### Architecture & Methodology
- [ ] **docs/architecture/FRAMEWORK.md** - Create FRAMEWORK.nl.md
- [ ] **docs/DECISION_RULES.md** - Create DECISION_RULES.nl.md
- [ ] **AI_CHAT_GUIDE.md** - Create AI_CHAT_GUIDE.nl.md
- [ ] **AI_CASE_ADVISOR.md** - Create AI_CASE_ADVISOR.nl.md

### Case Studies
- [ ] **Layer 0 Webshop** - Currently NL, create EN version
  - [ ] docs/cases/PRIORITY_0_WEBSHOP_CASE.md → .en.md
- [ ] **Layer 1 Webshop** - Currently NL, create EN version
  - [ ] docs/cases/PRIORITY_1_WEBSHOP_CASE.md → .en.md
- [ ] **Layer 2 Webshop** - Currently NL, create EN version
  - [ ] docs/cases/PRIORITY_2_WEBSHOP_CASE.md → .en.md

### Implementation Guides
- [ ] **docs/implementation/TESTING_METHODOLOGY.md** - Create .nl.md
- [ ] **docs/implementation/PRODUCTION_READY.md** - Create .nl.md
- [ ] **docs/TRANSIP_INFRASTRUCTURE_AS_CODE.md** - Create .en.md (currently NL-focused)

---

## Phase 3: Technical Implementation (Priority: MEDIUM)

### Language Switching Infrastructure
- [ ] Create language detection/selection system
  - [ ] Browser language detection
  - [ ] LocalStorage preference saving
  - [ ] URL parameter support (`?lang=nl`)
- [ ] Implement language toggle component
  - [ ] 🌐 EN/NL switcher in navbar
  - [ ] Persist selection across pages
  - [ ] Update all page links
- [ ] Create translation JSON files
  - [ ] `translations/en.json`
  - [ ] `translations/nl.json`
- [ ] Add translation helper script
  - [ ] `scripts/i18n-helper.js` for dynamic content

### File Structure
Decide on naming convention:
- **Option A**: Separate files (`file.en.html`, `file.nl.html`)
- **Option B**: Single file with JS translation (`file.html` + JSON)
- **Option C**: Subdirectories (`en/file.html`, `nl/file.html`)

**Recommendation**: Option B for HTML, Option A for Markdown

---

## Phase 4: Content Quality (Priority: LOW)

### Translation Review
- [ ] Native NL speaker review of EN→NL translations
- [ ] Native EN speaker review of NL→EN translations
- [ ] Technical term consistency check
  - [ ] Create glossary (GitOps, CNI, observability, etc.)
  - [ ] Decide: translate or keep English terms?
- [ ] Tone consistency (opinionated but professional)

### SEO & Metadata
- [ ] Add `<html lang="en">` / `lang="nl"` tags
- [ ] Translate meta descriptions
- [ ] Add `hreflang` tags for language alternates
- [ ] Update sitemap with language versions

---

## Phase 5: Automation (Priority: LOW)

### CI/CD for Translations
- [ ] GitHub Action to validate translation completeness
- [ ] Check for missing translation keys
- [ ] Warn on untranslated content in PRs
- [ ] Auto-generate translation status report

### Community Contributions
- [ ] Create TRANSLATION_GUIDE.md
- [ ] Add translation contribution workflow
- [ ] Set up translation review process
- [ ] Label system for translation PRs

---

## Implementation Notes

### Current State
- **NL Content**: Layer 0/1/2 case studies, some docs
- **EN Content**: README, framework docs, most HTML
- **Mixed**: Comparisons have EN structure with some NL terms

### Translation Priorities
1. **High**: User-facing UI (HTML pages, wizard, comparisons)
2. **Medium**: Core documentation (README, guides, framework)
3. **Low**: Implementation details, runbooks, technical specs

### Quality Guidelines
- **Consistent terminology** - maintain glossary
- **Cultural adaptation** - not literal translation
- **Technical accuracy** - preserve meaning of technical terms
- **Opinionated tone** - maintain KubeCompass voice in both languages

### Resources Needed
- Native speakers for review (both EN and NL)
- Translation memory tool (optional)
- Community feedback on terminology preferences

---

## Success Criteria
- [ ] All user-facing pages have EN/NL versions
- [ ] Language switcher works on all pages
- [ ] Core documentation available in both languages
- [ ] Translation quality reviewed by native speakers
- [ ] Automated checks prevent untranslated content

---

## Related Issues
- Link to specific translation tasks as they're created
- Link to terminology discussions
- Link to community feedback threads
