# Aan de Slag met KubeCompass

**Welkom bij KubeCompass!** Deze gids helpt je stap voor stap op weg met het project, of je nu nieuw bent met Kubernetes of al ervaring hebt.

---

## 🎯 Wat is KubeCompass?

KubeCompass biedt **praktische, hands-on guidance** voor het bouwen van production-ready Kubernetes platforms - zonder vendor marketing en buzzwords.

### Kernprincipes

✅ **Opinionated maar transparant** - Wij geven eerlijke aanbevelingen met data zodat je zelf weloverwogen keuzes kunt maken  
✅ **Hands-on getest** - Elke tool is daadwerkelijk gebruikt, niet alleen onderzocht  
✅ **Timing guidance** - Weet wat je meteen moet beslissen vs. wat later kan  
✅ **Transparante scoring** - Maturity, lock-in risico, operational complexity  
✅ **Geen vendor bias** - Gebouwd door practitioners, voor practitioners

### Voor wie is dit?

**Primaire doelgroep:**
- DevOps engineers
- SREs en platform engineers  
- Developers die Kubernetes willen leren

**Dit is:**
- Een pragmatische gids voor **practitioners** die echte beslissingen moeten nemen
- Gericht op **"hoe krijg ik dit werkend en houd ik het draaiend"**
- Bottom-up: gebouwd door engineers, voor engineers

**Dit is NIET:**
- Een compliance-first framework voor banken of zorg
- Een top-down governance manual
- Een vendor vergelijking voor inkoop teams

---

## 🚀 Snel Starten

### Optie 1: Interactive Tool Selector 🛒

De snelste manier om gepersonaliseerde aanbevelingen te krijgen:

1. Open `tool-selector-wizard.html` in je browser
2. Beantwoord vragen over jouw situatie (schaal, prioriteiten, voorkeuren)
3. Krijg instant tool aanbevelingen
4. Exporteer resultaten naar Markdown of JSON

### Optie 2: AI Case Advisor 🤖

Gebruik AI voor gepersonaliseerd advies:

1. Lees [`AI_CHAT_GUIDE.md`](AI_CHAT_GUIDE.md)
2. Kopieer prompts voor ChatGPT, Claude of Gemini
3. Beantwoord 5 kritieke vragen over je organisatie
4. Ontvang "Kies X tenzij Y" beslissingsregels

### Optie 3: Visual Diagrams 🎨

Verken visueel het Kubernetes landschap:

- 🌊 [Complete Deployment Flow](../deployment-flow.html) - Alle 18 domeinen in volgorde
- 📊 [Domain Overview](../domain-overview.html) - Georganiseerd per prioriteit
- 🗓️ [Timeline View](../deployment-order.html) - Week-by-week roadmap
- 🚢 [Kubernetes Ecosystem](../kubernetes-ecosystem.html) - Kleurrijk overzicht
- ⚙️ [Kubernetes Architecture](../kubernetes-architecture.html) - Technische visualisatie

---

## 🧪 Lokaal Testen met Kind

Test Kubernetes concepten lokaal zonder cloud kosten.

### Vereisten

- **Docker Desktop** (Windows) of **Docker Engine** (Linux)
- **kubectl** - Kubernetes command-line tool
- **kind** - Kubernetes in Docker
- **Git** - Version control

### Installatie

#### Windows (PowerShell)

```powershell
# Installeer kind
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe C:\Windows\System32\kind.exe

# Installeer kubectl
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
Move-Item .\kubectl.exe C:\Windows\System32\kubectl.exe

# Controleer
kind version
kubectl version --client
docker version
```

#### Linux/WSL (Bash)

```bash
# Installeer kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Installeer kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Controleer
kind version
kubectl version --client
docker version
```

### Je Eerste Cluster

```bash
# Clone repository
git clone https://github.com/vanhoutenbos/KubeCompass.git
cd KubeCompass

# Maak base cluster (Windows)
.\kind\create-cluster.ps1

# Maak base cluster (Linux/WSL)
./kind/create-cluster.sh

# Valideer cluster
kubectl cluster-info
kubectl get nodes

# Run smoke tests (Windows)
.\tests\smoke\run-tests.ps1

# Run smoke tests (Linux)
./tests/smoke/run-tests.sh

# Deploy test workloads
kubectl apply -f manifests/namespaces/
kubectl apply -f manifests/base/

# Test connectivity
curl http://localhost:8080
```

### Test Verschillende CNIs

#### Cilium

```bash
# Maak Cilium cluster
./kind/create-cluster.sh cilium

# Installeer Cilium
cilium install

# Controleer
cilium status
```

#### Calico

```bash
# Maak Calico cluster
./kind/create-cluster.sh calico

# Installeer Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Controleer
kubectl get pods -n kube-system
```

### Multi-Node Cluster

```bash
# Maak multi-node cluster
./kind/create-cluster.sh multinode

# Bekijk nodes
kubectl get nodes
```

---

## 📚 Leerpad

### 1. Beginner (8-12 uur)

Voor wie nieuw is met Kubernetes of KubeCompass:

1. **[Vision](architecture/VISION.md)** (20 min) - Begrijp de filosofie
2. **[Framework](architecture/FRAMEWORK.md)** (1 uur) - Leer de decision landscape
3. **Lokale Setup** (2 uur) - Maak je eerste cluster
4. **[Kind Documentation](../kind/README.md)** (2 uur) - Verdiep je in cluster management
5. **Smoke Tests** (30 min) - Valideer je setup
6. **[Decision Matrix](MATRIX.md)** (1 uur) - Verken tool aanbevelingen
7. **[CNI Comparison](planning/CNI_COMPARISON.md)** (1 uur) - Eerste technische deep-dive
8. **[Priority 1 Case Study](cases/PRIORITY_1_WEBSHOP_CASE.md)** (2 uur) - Real-world voorbeeld

### 2. Intermediate (4-6 uur)

Voor wie al Kubernetes kennis heeft:

1. **[Framework](architecture/FRAMEWORK.md)** (30 min) - Snelle overview
2. **[Decision Matrix](MATRIX.md)** (30 min) - Tool landscape
3. **[Decision Rules](DECISION_RULES.md)** (30 min) - "Kies X tenzij Y" logica
4. **[CNI Comparison](planning/CNI_COMPARISON.md)** (45 min) - Networking deep-dive
5. **[GitOps Guide](planning/GITOPS_GITLAB.md)** (45 min) - GitOps in praktijk
6. **[Priority 1 Case Study](cases/PRIORITY_1_WEBSHOP_CASE.md)** (1.5 uur) - Tool selectie proces
7. **[Production Ready](implementation/PRODUCTION_READY.md)** (30 min) - Production criteria

### 3. Advanced (2-3 uur)

Voor ervaren platform engineers:

1. **[Architecture Review](architecture/ARCHITECTURE_REVIEW_SUMMARY.md)** (30 min) - Structured decision support
2. **[Priority 0→1 Mapping](cases/PRIORITY_0_PRIORITY_1_MAPPING.md)** (30 min) - Requirements traceability
3. **[Decision Rules](DECISION_RULES.md)** (20 min) - Automation-ready rules
4. **[Open Questions](planning/OPEN_QUESTIONS.md)** (20 min) - Critical decisions
5. **[TransIP IaC Guide](TRANSIP_INFRASTRUCTURE_AS_CODE.md)** (20 min) - Vendor-specific IaC
6. **[Domain Roadmap](planning/DOMAIN_ROADMAP.md)** (30 min) - Implementation planning

---

## 🗺️ Framework & Methodologie

### Priority Model

KubeCompass gebruikt een **Priority 0/1/2** model voor beslissingen:

#### Priority 0: Day 1 Foundational Decisions
**Wanneer:** Week 1 - Voor je begint  
**Focus:** Beslissingen die moeilijk te veranderen zijn en extreme impact hebben

Architectuurbeslissingen die je vanaf dag 1 moet maken omdat ze later duur of bijna onmogelijk te wijzigen zijn:
- **CNI (Container Network Interface)** - CNI wisselen na deployment is complex en risicovol
- **GitOps tooling** - Je deployment workflow moet vanaf het begin goed zijn
- **Telemetry foundations** - OTEL instrumentatie is makkelijker vroeg dan later toe te voegen
- **RBAC model** - Security model moet vooraf ontworpen worden
- **Storage architecture** - StatefulSet patronen en persistent volume strategie

Extra overwegingen:
- Availability requirements en downtime tolerantie
- Data criticality (RPO/RTO)
- Security baseline
- Vendor independence principes

**Document:** [Priority 0 Webshop Case](cases/PRIORITY_0_WEBSHOP_CASE.md) (Nederlands)

#### Priority 1: Core Platform Tools  
**Wanneer:** Week 2-4 - Basic platform  
**Focus:** Essentiële tools voor productie die relatief makkelijk te wisselen zijn

Tools die je nodig hebt voor een productie platform, maar die je eenvoudiger kunt vervangen dan Priority 0 beslissingen:
- **Monitoring stack** - Prometheus/Grafana vs. DataDog vs. VictoriaMetrics
- **Secrets management** - External Secrets Operator vs. Sealed Secrets
- **Ingress controller** - Nginx vs. Traefik vs. Envoy Gateway
- **CI/CD pipeline** - Jenkins vs. GitLab CI vs. GitHub Actions

Aanvullend:
- Managed Kubernetes selectie
- Observability stack
- Security implementation (secrets, image scanning)
- Migration roadmap

**Document:** [Priority 1 Webshop Case](cases/PRIORITY_1_WEBSHOP_CASE.md) (Nederlands)

#### Priority 2: Advanced Enhancements
**Wanneer:** Maand 2+ - Na basis platform draait  
**Focus:** Geavanceerde mogelijkheden om toe te voegen wanneer specifieke behoeften ontstaan

Geavanceerde tools die complexiteit toevoegen maar specifieke problemen oplossen. Voeg ze toe wanneer je een duidelijke behoefte hebt, niet "voor het geval dat":
- Service mesh - Toevoegen bij 10+ microservices met complexe traffic routing
- Distributed tracing - Toevoegen wanneer debuggen van inter-service issues tijdrovend wordt
- Chaos engineering - Toevoegen wanneer je veerkracht op schaal moet valideren
- Policy enforcement - OPA/Kyverno voor complexe governance behoeften
- Cost visibility - Wanneer kostenoptimalisatie prioriteit wordt
- Multi-region readiness - Wanneer geografische distributie noodzakelijk wordt

**Document:** [Priority 2 Webshop Case](cases/PRIORITY_2_WEBSHOP_CASE.md) (Nederlands)

**Let op:** Priority 2 is **geen implementation guide** maar een **decision framework** - het helpt je beslissen WANNEER complexiteit toevoegen zinvol wordt.

### Decision Framework

Voor elk domein hebben we:

1. **"Kies X tenzij Y" regels** - Clear decision logic
2. **Tool comparisons** - Hands-on getest
3. **Timing guidance** - Wanneer beslissen
4. **Exit strategy** - Hoe moeilijk is migreren
5. **Production criteria** - Wanneer is het production-ready

**Lees meer:** [Decision Rules](DECISION_RULES.md)

---

## 🎯 Gebruik per Rol

### Platform Engineer

**Getting Started:**
1. [Lokale Setup](#-lokaal-testen-met-kind)
2. [Docker Installation](DOCKER_INSTALLATION.md)
3. [Kind Setup](../kind/README.md)

**Planning:**
1. [Priority 0 Case Study](cases/PRIORITY_0_WEBSHOP_CASE.md) - Requirements
2. [Priority 1 Case Study](cases/PRIORITY_1_WEBSHOP_CASE.md) - Tool selectie
3. [Decision Matrix](MATRIX.md) - Tool overzicht

**Implementation:**
1. [Implementation Guide](IMPLEMENTATION_GUIDE.md) - Reference patterns
2. [Production Ready](implementation/PRODUCTION_READY.md) - Criteria
3. [Deployment Runbook](runbooks/deployment.md) - Operations

**Tool Selectie:**
1. [CNI Comparison](planning/CNI_COMPARISON.md) - Networking
2. [GitOps Comparison](planning/GITOPS_COMPARISON.md) - GitOps tools
3. [Secrets Management](planning/SECRETS_MANAGEMENT.md) - Secrets

### Architect

**Strategy:**
1. [Framework](architecture/FRAMEWORK.md) - Complete domain structuur
2. [Vision](architecture/VISION.md) - Filosofie en principes
3. [Architecture Review](architecture/ARCHITECTURE_REVIEW_SUMMARY.md) - Decision support

**Decision Support:**
1. [Decision Matrix](MATRIX.md) - Tool aanbevelingen
2. [Priority 0→1 Mapping](cases/PRIORITY_0_PRIORITY_1_MAPPING.md) - Traceability
3. [Open Questions](planning/OPEN_QUESTIONS.md) - Kritieke vragen

**Scenarios:**
1. [Enterprise Multi-tenant](planning/SCENARIOS.md) - Enterprise scenario
2. [Webshop Case Studies](cases/) - Real-world cases
3. [CNCF Alignment](planning/CNCF_ALIGNMENT.md) - Landscape mapping

### Developer

**Getting Started:**
1. [Lokale Setup](#-lokaal-testen-met-kind)
2. [Manifests Guide](../manifests/README.md) - Kubernetes resources
3. [Testing Guide](../tests/README.md) - Test suites

**Tools:**
1. [Tool Selector Wizard](../tool-selector-wizard.html) - Interactive selectie
2. [GitOps Guide](planning/GITOPS_GITLAB.md) - GitOps in praktijk
3. [RBAC Examples](../manifests/rbac/README.md) - Security patterns

---

## 🔧 Veelvoorkomende Taken

### "Ik moet een CNI kiezen"
→ [CNI Comparison](planning/CNI_COMPARISON.md) - Cilium vs Calico vs Flannel

### "Ik moet een GitOps tool kiezen"
→ [GitOps Comparison](planning/GITOPS_COMPARISON.md) - ArgoCD vs Flux vs GitLab  
→ [ArgoCD Guide](planning/ARGOCD_GUIDE.md) - Hands-on walkthrough  
→ [Flux Guide](planning/FLUX_GUIDE.md) - Bootstrap to production

### "Ik moet een lokaal test cluster opzetten"
→ [Lokaal Testen met Kind](#-lokaal-testen-met-kind)

### "Ik wil het framework begrijpen"
→ [Framework](architecture/FRAMEWORK.md)  
→ [Vision](architecture/VISION.md)

### "Ik zoek een real-world voorbeeld"
→ [Webshop Case Studies](cases/) (Nederlands)  
→ [Scenarios](planning/SCENARIOS.md)

### "Ik moet beslissingen maken"
→ [Decision Matrix](MATRIX.md)  
→ [Decision Rules](DECISION_RULES.md)

### "Ik wil iets deployen"
→ [Manifests Guide](../manifests/README.md)  
→ [Deployment Runbook](runbooks/deployment.md)

### "Ik moet secrets veilig beheren"
→ [Secrets Management](planning/SECRETS_MANAGEMENT.md) - ESO vs Sealed Secrets vs SOPS

### "Ik wil security policies testen"
→ [RBAC Examples](../manifests/rbac/README.md) - 8 production-ready patterns  
→ [Network Policies](../manifests/networking/README.md) - Zero-trust networking  
→ [Security Tests](../tests/security/README.md) - Automated validation

### "Ik zoek production criteria"
→ [Production Ready](implementation/PRODUCTION_READY.md)  
→ [Implementation Guide](IMPLEMENTATION_GUIDE.md)

---

## 📖 Documentatie Structuur

```
docs/
├── AAN_DE_SLAG.md          # ← Je bent hier! (Nederlands)
├── GETTING_STARTED.md      # English version
├── INDEX.md                # Complete documentatie index
│
├── architecture/           # Framework & Philosophy
│   ├── FRAMEWORK.md        # Complete domain structuur
│   ├── VISION.md           # Project filosofie
│   ├── METHODOLOGY.md      # Tool evaluation methode
│   └── ARCHITECTURE_REVIEW_SUMMARY.md
│
├── cases/                  # Case Studies (Nederlands)
│   ├── PRIORITY_0_WEBSHOP_CASE.md  # Foundational requirements
│   ├── PRIORITY_1_WEBSHOP_CASE.md  # Tool selection
│   ├── PRIORITY_2_WEBSHOP_CASE.md  # Enhancement decisions
│   ├── UNIFIED_CASE_STRUCTURE.md
│   └── CASE_ANALYSIS_TEMPLATE.md
│
├── planning/               # Planning & Comparisons
│   ├── CNI_COMPARISON.md
│   ├── GITOPS_COMPARISON.md
│   ├── SECRETS_MANAGEMENT.md
│   ├── DOMAIN_ROADMAP.md
│   ├── SCENARIOS.md
│   └── ...
│
├── implementation/         # Implementation Guides
│   ├── IMPLEMENTATION_GUIDE.md
│   ├── PRODUCTION_READY.md
│   ├── TESTING_METHODOLOGY.md
│   └── LAUNCH_PLAN.md
│
├── runbooks/              # Operational Procedures
│   ├── deployment.md
│   ├── disaster-recovery.md
│   └── transip-cluster-provisioning.md
│
├── domains/               # Domain-specific docs
├── portability/           # Multi-cloud guidance
├── providers/             # Provider-specific info
└── archief/              # Oude/gearchiveerde documenten
```

---

## 🤝 Bijdragen

Wil je helpen? Geweldig!

### Manieren om bij te dragen:

**Quick (15-30 min):**
- Fix typos en broken links
- Voeg voorbeelden toe
- Rapporteer outdated informatie

**Medium (1-2 uur):**
- Documentatie verbeteringen
- Troubleshooting guides
- Vergelijkings artikelen

**Deep (4-8 uur):**
- Tool reviews met hands-on testing
- Real-world scenario's
- Architectural diagrams

**Lees meer:** [Contributing Guide](../CONTRIBUTING.md)

### Quality Standards

- Clear, beknopte taal
- Code examples moeten getest zijn
- Internal links moeten werken
- Consistent met project tone (practical, honest, opinionated)

---

## 🆘 Hulp & Support

### Veelgestelde Vragen

- **"Waar begin ik?"** → Je bent al op de goede plek! Start met [Snel Starten](#-snel-starten)
- **"Wat is KubeCompass?"** → Zie [Wat is KubeCompass](#-wat-is-kubecompass)
- **"Hoe draag ik bij?"** → [Contributing Guide](../CONTRIBUTING.md)
- **"Welke tools moet ik gebruiken?"** → [Decision Matrix](MATRIX.md)
- **"Hoe test ik lokaal?"** → [Lokaal Testen](#-lokaal-testen-met-kind)

### Troubleshooting

- **Docker problemen** → [Docker Installation](DOCKER_INSTALLATION.md)
- **Kind problemen** → [Kind README](../kind/README.md)
- **Test failures** → [Testing Guide](../tests/README.md)

### Betrokken Raken

- **GitHub Issues**: https://github.com/vanhoutenbos/KubeCompass/issues
- **Discussions**: https://github.com/vanhoutenbos/KubeCompass/discussions
- **Contributing**: [Contributing Guide](../CONTRIBUTING.md)

---

## 📜 Project Status

**Huidige Fase:** 🚧 POC/Research - actief bezig met foundation bouwen

**Domain Coverage:**
- ✅ Fully Tested: 0/18 domains
- 📝 Theory Documented: 2/18 domains (CNI, GitOps)
- 🚧 In Progress: 4/18 domains (RBAC, Network Policies, Observability, CI/CD)
- ❌ Not Started: 12/18 domains

**Target Launch:** Mid-March 2026 (Week 12)

**Lees meer:** [Domain Roadmap](planning/DOMAIN_ROADMAP.md)

---

## 📝 Licentie

Dit project is gelicenseerd onder de **MIT License** - gebruik het vrij, draag bij als je het nuttig vindt.

---

**Gebouwd door [@vanhoutenbos](https://github.com/vanhoutenbos) en contributors.**

**Vind je KubeCompass nuttig? Geef het een ⭐ en vertel het verder!**
