# Kubernetes Ecosysteem Infographic

🚢 **Een visuele reis door het Kubernetes platform**

---

## Overzicht

Deze infographic visualiseert het Kubernetes ecosysteem als een schip dat wordt bestuurd door een kapitein (jij!). Het schip heeft drie lagen die de architectuur van een productie-ready Kubernetes platform representeren, elk met hun eigen karakters die verschillende domeinen vertegenwoordigen.

### 🎨 **Design Concept**

De infographic is geïnspireerd op:
- Het **Scaled Agile Framework** - interactieve, klikbare domeinen
- De **Linux pinguin** en vergelijkbare tech mascots - vriendelijke, herkenbare karakters
- **Kubernetes architectuur diagrammen** - maar dan toegankelijker en visueler

### 🌈 **Kleurenschema**

| Kleur | Laag | Betekenis |
|-------|------|-----------|
| 🔴 **Rood** | Laag 0: Fundament | Beslissen op Dag 1 - Moeilijk te veranderen |
| 🟡 **Geel** | Laag 1: Kernfuncties | Implementeren in Maand 1 - Belangrijk voor dagelijks gebruik |
| 🟢 **Groen** | Laag 2: Verbeteringen | Toevoegen wanneer nodig - Makkelijk uit te breiden |

---

## 📁 Bestanden

### Hoofdbestanden
- **`kubernetes-ecosystem-infographic.svg`** - De hoofdinfographic in bewerkbaar SVG formaat
- **`kubernetes-ecosystem.html`** - HTML viewer met uitleg en download optie
- **`INFOGRAPHIC_README.md`** - Dit bestand

### Structuur
```
KubeCompass/
├── kubernetes-ecosystem-infographic.svg    # Bewerkbare infographic
├── kubernetes-ecosystem.html               # Interactive viewer
└── INFOGRAPHIC_README.md                   # Documentatie
```

---

## 🎭 De Karakters en Domeinen

### Laag 0: Fundament (Rood - Dag 1 beslissingen)

Deze basis moet op dag 1 goed zijn, want later veranderen is kostbaar:

| Karakter | Domein | Emoji | Beschrijving |
|----------|--------|-------|--------------|
| **Bouwvakker** | Infrastructuur | 🏗️ | Bouwt en beheert de basis infrastructuur |
| **Beveiliger** | Beveiliging | 🛡️ | Beschermt het platform met identity & access management |
| **Postbode** | Netwerken | 🌐 | Zorgt voor communicatie tussen componenten (CNI) |
| **Versie Beheerder** | GitOps | 🔄 | Houdt alles gesynchroniseerd via Git |
| **Raket Ingenieur** | CI/CD | 🚀 | Lanceert applicaties naar productie |

### Laag 1: Kernfuncties (Geel - Maand 1 implementatie)

Essentieel voor dagelijks gebruik:

| Karakter | Domein | Emoji | Beschrijving |
|----------|--------|-------|--------------|
| **Detective** | Observatie | 🔍 | Monitort en analyseert het platform |
| **Bibliothecaris** | Opslag | 💾 | Beheert persistente data |
| **Magazijnbeheerder** | Container Registry | 📦 | Slaat en distribueert container images |
| **Boodschapper** | Berichten | 📨 | Verzorgt asynchrone communicatie |
| **Database Admin** | Databases | 🗄️ | Beheert datastores |
| **Snelheidsduivel** | Caching | ⚡ | Versnelt data toegang |
| **Kluisbewaarder** | Geheimen | 🔐 | Beheert secrets en credentials |

### Laag 2: Verbeteringen (Groen - Toevoegen wanneer nodig)

Plug-and-play uitbreidingen:

| Karakter | Domein | Emoji | Beschrijving |
|----------|--------|-------|--------------|
| **Doelgericht** | App Deployment | 🎯 | Geavanceerde deployment strategieën |
| **Nachtwaker** | Runtime Security | 🔒 | Bewaakt het platform tijdens runtime |
| **Developer** | Developer Experience | 👨‍💻 | Verbetert de workflow voor developers |
| **Rechter** | Governance | ⚖️ | Handhaaft beleid en compliance |
| **Accountant** | Kosten | 💰 | Monitort en optimaliseert kosten |
| **Wetenschapper** | Chaos Testing | 🔬 | Test de veerkracht van het platform |
| **Archivist** | Backup/DR | 💿 | Zorgt voor disaster recovery |

---

## 🚢 De Kapitein

De **Kubernetes Kapitein** staat centraal in de infographic. Dit ben jij - de platform engineer, SRE, of DevOps specialist die het schip bestuurt. De kapitein:

- Draagt een kapiteinshoed met het Kubernetes logo
- Houdt het stuurwiel vast (controle over het platform)
- Staat op het dek van het schip (overzicht over alle lagen)
- Heeft een vriendelijke uitstraling (toegankelijk, niet intimiderend)

---

## 🛠️ Bewerken van de Infographic

### SVG Bewerkingsprogramma's

De infographic kan bewerkt worden in:

1. **Inkscape** (Gratis, Open Source)
   - Download: https://inkscape.org/
   - Beste optie voor Linux en open-source workflow
   
2. **Adobe Illustrator** (Commercieel)
   - Professionele tool voor designers
   - Volledige SVG ondersteuning
   
3. **Figma** (Gratis/Commercieel)
   - Browser-based, geen installatie nodig
   - Import SVG via File → Import
   
4. **Affinity Designer** (Eenmalige aankoop)
   - Betaalbaar alternatief voor Illustrator

### Bewerkingstips

- **Groepen**: Elk domein is een groep (`<g>`) met ID en classes
- **Kleuren**: Gebruik de bestaande gradients voor consistentie
- **Karakters**: Emojis zijn gemakkelijk te vervangen door andere icons
- **Tekst**: Nederlandse teksten kunnen worden aangepast naar Engels of andere talen
- **Export**: Exporteer naar PNG voor presentaties, houd SVG voor web

---

## 🔗 Interactief Maken

De infographic is voorbereid voor interactiviteit. Elk domein heeft:

- Een uniek `id` attribuut (bijv. `id="infrastructure"`)
- Een `class="domain"` voor styling
- Een `data-domain` attribuut voor JavaScript interactie

### Voorbeeld 1: Klikbare Gebieden naar Documentatie

```javascript
// Laad het SVG object
const svgObject = document.getElementById('infographic');
const svgDoc = svgObject.contentDocument;

// Voeg click handlers toe aan alle domeinen
svgDoc.querySelectorAll('.domain').forEach(domain => {
    domain.style.cursor = 'pointer';
    
    domain.addEventListener('click', () => {
        const domainName = domain.dataset.domain;
        // Navigeer naar relevante documentatie
        window.location.href = `docs/domains/${domainName}.md`;
    });
});
```

### Voorbeeld 2: Tooltips bij Hover

```javascript
svgDoc.querySelectorAll('.domain').forEach(domain => {
    const domainName = domain.dataset.domain;
    
    // Maak tooltip element
    const tooltip = document.createElement('div');
    tooltip.className = 'tooltip';
    tooltip.textContent = getDomainDescription(domainName);
    
    domain.addEventListener('mouseenter', (e) => {
        tooltip.style.left = e.pageX + 'px';
        tooltip.style.top = e.pageY + 'px';
        document.body.appendChild(tooltip);
    });
    
    domain.addEventListener('mouseleave', () => {
        tooltip.remove();
    });
});
```

### Voorbeeld 3: Laag Filtering

```javascript
// Toggle visibility per laag
function toggleLayer(layerNumber) {
    const layer = svgDoc.getElementById(`layer${layerNumber}`);
    const currentOpacity = layer.getAttribute('opacity') || '1';
    layer.setAttribute('opacity', currentOpacity === '1' ? '0.2' : '1');
}

// Buttons in HTML
<button onclick="toggleLayer(0)">Toggle Laag 0</button>
<button onclick="toggleLayer(1)">Toggle Laag 1</button>
<button onclick="toggleLayer(2)">Toggle Laag 2</button>
```

### Voorbeeld 4: Highlight op Klik

```javascript
let selectedDomain = null;

svgDoc.querySelectorAll('.domain').forEach(domain => {
    domain.addEventListener('click', function() {
        // Reset vorige selectie
        if (selectedDomain) {
            selectedDomain.style.filter = 'none';
        }
        
        // Highlight nieuwe selectie
        this.style.filter = 'drop-shadow(0 0 10px #FFD700)';
        selectedDomain = this;
        
        // Toon info panel
        showDomainInfo(this.dataset.domain);
    });
});
```

---

## 🎯 Use Cases

### 1. Presentaties

- Gebruik voor stakeholder presentaties
- Export naar PNG of PDF voor slides
- Print als poster voor in de teamruimte

### 2. Documentatie

- Embed in README of Wiki
- Link naar specifieke domeinen in documentatie
- Gebruik als navigatie tool

### 3. Onboarding

- Toon nieuwe teamleden het platform overzicht
- Gebruik als startpunt voor training
- Print als handout voor workshops

### 4. Interactive Website (Toekomst)

- Implementeer als hoofdnavigatie voor KubeCompass site
- Maak klikbaar zoals Scaled Agile Framework
- Voeg animaties toe voor betere UX

### 5. Tool Selection

- Gebruik om te visualiseren welke tools in welke laag vallen
- Highlight specifieke paden voor verschillende scenarios
- Toon afhankelijkheden tussen domeinen

---

## 📐 Technische Details

### SVG Structuur

```xml
<svg viewBox="0 0 1600 1200">
  <defs>
    <!-- Gradients en filters -->
  </defs>
  
  <!-- Achtergrond -->
  <rect fill="url(#skyGradient)"/>
  
  <!-- Laag 0: Fundament -->
  <g id="layer0" class="layer" data-layer="0">
    <g id="infrastructure" class="domain" data-domain="infrastructure">
      <!-- Domein content -->
    </g>
  </g>
  
  <!-- Laag 1: Kernfuncties -->
  <g id="layer1" class="layer" data-layer="1">
    <!-- Domeinen -->
  </g>
  
  <!-- Laag 2: Verbeteringen -->
  <g id="layer2" class="layer" data-layer="2">
    <!-- Domeinen -->
  </g>
  
  <!-- Kapitein en decoratie -->
  <g id="captain">
    <!-- Kapitein karakter -->
  </g>
</svg>
```

### CSS Classes

- `.layer` - Elke laag groep
- `.domain` - Elk domein binnen een laag
- `#captain` - De hoofdkarakter (kapitein)
- `#platformBase` - Het schip platform

### Data Attributes

- `data-layer="0|1|2"` - Laag nummer
- `data-domain="domainname"` - Domein identificatie

---

## 🚀 Next Steps

### Directe Verbeteringen

1. **Export naar PNG/PDF** - Voor presentaties
2. **Vertaling naar Engels** - Voor internationale use
3. **Print versie** - Optimaliseren voor A1 poster
4. **Dark mode variant** - Voor donkere achtergronden

### Interactieve Features (Toekomst)

1. **Click to Learn** - Klik op domein → toon documentatie
2. **Guided Tour** - Stap-voor-stap uitleg met animaties
3. **Scenario Highlighting** - Highlight relevante domeinen per scenario
4. **Tool Overlay** - Toon specifieke tools per domein on demand
5. **Dependency Visualization** - Toon afhankelijkheden bij hover

### Geavanceerde Features

1. **Animated Journey** - Animatie van deployment flow
2. **Multi-language Support** - Toggle tussen NL/EN/DE
3. **Customization** - Gebruikers kunnen eigen tools invullen
4. **Export to Canvas** - Genereer aangepaste versie voor eigen org
5. **Integration met KubeCompass Wizard** - Koppel aan tool selector

---

## 🎓 Vergelijking met Inspiratiebronnen

### Scaled Agile Framework (SAFe)

**Wat we hebben overgenomen:**
- Klikbare domeinen die naar documentatie linken
- Gelaagde structuur (layers)
- Visuele navigatie door complexe onderwerpen

**Wat anders is:**
- Focus op Kubernetes platform i.p.v. agile methodologie
- Gebruik van karakters/mascots voor toegankelijkheid
- Minder formeel, meer speels

### Kubernetes Architectuur Diagrammen

**Wat we hebben overgenomen:**
- Basis architectuur (fundament → core → add-ons)
- Domein indeling
- Technische accuratesse

**Wat anders is:**
- Geen specifieke tools benoemd
- Karakters representeren functionaliteit
- Focus op decision journey i.p.v. technische implementatie

### D2IQ en Vergelijkbare Infographics

**Wat we hebben overgenomen:**
- Ecosysteem overzicht
- Visuele categorisering
- Kleurcodering

**Wat anders is:**
- KubeCompass terminologie en framework
- Focus op beslissingen en timing
- Nederlandse context en taalgebruik

---

## 📝 Licentie en Gebruik

These infographics are part of the **KubeCompass** project and fall under the **MIT License**.

✅ **You may:**
- Use the infographic in presentations
- Customize for your own organization
- Share with credits to KubeCompass
- Print as poster or handout
- Embed in your own documentation

❌ **You may not:**
- Sell the infographic without modifications
- Claims maken alsof je het origineel hebt gemaakt
- Gebruiken zonder credit als je het online deelt

**Credit:** Als je deze infographic gebruikt, vermeld dan:
```
Bron: KubeCompass - https://github.com/vanhoutenbos/KubeCompass
```

---

## 🤝 Bijdragen

Wil je de infographic verbeteren? Geweldig!

### Ideeën voor Bijdragen

1. **Nieuwe karakters** - Betere visualisaties voor domeinen
2. **Animaties** - SVG animaties toevoegen
3. **Vertalingen** - Andere talen dan Nederlands
4. **Interactieve versie** - Volledige HTML/JS implementatie
5. **Alternative stijlen** - Verschillende design variants

### Hoe Bijdragen

1. Fork de repository
2. Maak je aanpassingen in `kubernetes-ecosystem-infographic.svg`
3. Test in `kubernetes-ecosystem.html`
4. Submit een Pull Request met uitleg

---

## 📞 Contact en Feedback

- **GitHub Issues**: Voor bugs en feature requests
- **GitHub Discussions**: Voor algemene vragen en ideeën
- **Pull Requests**: Voor concrete verbeteringen

---

## 🗺️ Roadmap

### Q1 2026
- [x] Basis infographic met alle domeinen
- [x] HTML viewer met basis interactie
- [ ] Export naar PNG/PDF
- [ ] Engelse versie

### Q2 2026
- [ ] Volledige interactieve website
- [ ] Klikbare domeinen naar documentatie
- [ ] Animated tour voor nieuwe gebruikers
- [ ] Tool overlay systeem

### Q3 2026
- [ ] Scenario-based highlighting
- [ ] Customization tools
- [ ] Multi-language support
- [ ] Integration met AI Case Advisor

---

## 🎨 Design Beslissingen

### Waarom een Schip?

Een Kubernetes platform is als een schip:
- **Fundament (romp)**: Draagt alles, moet stevig zijn
- **Kernfuncties (motoren)**: Zorgen dat het beweegt
- **Verbeteringen (uitrusting)**: Kunnen later worden toegevoegd
- **Kapitein (jij)**: Stuurt het geheel

### Waarom Karakters?

Karakters maken technologie toegankelijk:
- **Herkenbaar**: Iedereen kent het concept van rollen
- **Memorabel**: Gemakkelijker te onthouden dan abstracte concepten
- **Vriendelijk**: Maakt Kubernetes minder intimiderend
- **Universeel**: Emojis werken in alle culturen

### Waarom Drie Lagen?

De drie-laags structuur komt uit de KubeCompass methodologie:
- **Laag 0**: Kostbaar om te veranderen → Rood (gevaar)
- **Laag 1**: Essentieel maar vervangbaar → Geel (let op)
- **Laag 2**: Flexibel toevoegbaar → Groen (veilig)

---

**Veel plezier met de infographic! 🚢**

Voor vragen of suggesties, open een issue of discussion in de [KubeCompass repository](https://github.com/vanhoutenbos/KubeCompass).
