# Kubernetes Architectuur Infographic

⚙️ **High-level overzicht van concepten en oplossingen - tool-agnostisch**

---

## Overzicht

Deze infographic visualiseert Kubernetes vanuit een **hoog niveau architectuur perspectief**. In tegenstelling tot de ecosysteem infographic die laat zien *welke domeinen* je moet invullen (security, observability, CI/CD), toont deze infographic *hoe Kubernetes technisch werkt* en waar elk component leeft.

**Nieuw:** Deze pagina bevat nu ook een **DevSecOps Pipeline infographic** die laat zien waar security maatregelen zoals CVE scanning, image signing, en runtime security plaatsvinden in de pipeline.

### 🎨 **Design Concept**

De infographic toont de complete Kubernetes stack van boven naar beneden, **zonder specifieke tools te noemen**:
- **Managed Kubernetes opties** (cloud providers en self-managed)
- **CI/CD Pipeline met GitOps** methodiek
- **Control Plane componenten** (API Server, Scheduler, etc.)
- **Worker Nodes** met alle Kubernetes objecten (Pods, Services, Deployments)
- **Service Mesh layer** die tussen de services leeft
- **Persistent Storage** voor data persistentie

### 🔒 **DevSecOps Pipeline**

De nieuwe DevSecOps pipeline infographic visualiseert de complete security journey:
- **Development:** SAST, Linting, Secrets Detection, Software Composition Analysis
- **Build & Test:** Image Scanning (CVE), Image Signing, SBOM generation
- **Registry:** Access Control, Re-scanning, Signature Verification
- **Deployment:** Admission Control, RBAC, Network Policies, Pod Security
- **Runtime:** Runtime Detection, Threat Detection & Response

### 🆚 **Verschil met Ecosysteem Infographic**

| Ecosysteem Infographic | Architectuur Infographic |
|------------------------|--------------------------|
| 🚢 Toont **welke domeinen** te implementeren | ⚙️ Toont **hoe Kubernetes werkt** |
| Laag 0/1/2 decision framework | Technische component layout |
| Focus op beslissingen en timing | Focus op architectuur en flow |
| Voor platform planning | Voor technische training |
| Karakters representeren domeinen | Echte Kubernetes componenten |

**Gebruik beide samen:** De ecosysteem infographic helpt je beslissen *wat* je nodig hebt, de architectuur infographic laat zien *hoe* het technisch werkt.

---

## 📁 Bestanden

### Hoofdbestanden
- **`kubernetes-architecture-infographic.svg`** - De hoofdinfographic in bewerkbaar SVG formaat (tool-agnostisch)
- **`kubernetes-devsecops-pipeline.svg`** - DevSecOps pipeline met security stages
- **`kubernetes-architecture.html`** - HTML viewer met beide infographics en uitleg
- **`KUBERNETES_ARCHITECTURE_README.md`** - Dit bestand

### Structuur
```
KubeCompass/
├── kubernetes-architecture-infographic.svg    # Architectuur infographic (tool-agnostic)
├── kubernetes-devsecops-pipeline.svg          # DevSecOps pipeline
├── kubernetes-architecture.html               # Interactive viewer
├── KUBERNETES_ARCHITECTURE_README.md          # Documentatie
├── kubernetes-ecosystem-infographic.svg       # Ecosysteem infographic (bestaand)
└── kubernetes-ecosystem.html                  # Ecosysteem viewer (bestaand)
```

### Structuur
```
KubeCompass/
├── kubernetes-architecture-infographic.svg    # Architectuur infographic
├── kubernetes-architecture.html               # Interactive viewer
├── KUBERNETES_ARCHITECTURE_README.md          # Documentatie
├── kubernetes-ecosystem-infographic.svg       # Ecosysteem infographic (bestaand)
└── kubernetes-ecosystem.html                  # Ecosysteem viewer (bestaand)
```

---

## 🏗️ Architectuur Lagen (van boven naar beneden)

### Laag 1: Managed Kubernetes Opties ☁️

Waar haal je je Kubernetes cluster vandaan?

| Provider | Beschrijving | Voordelen | Nadelen |
|----------|--------------|-----------|---------|
| **Azure AKS** | Microsoft's managed Kubernetes | Goede Azure integratie, auto-upgrades | Vendor lock-in, Azure-specifieke features |
| **AWS EKS** | Amazon's managed Kubernetes | Beste AWS integratie, mature | Duurder dan alternatieven |
| **Google GKE** | Google's managed Kubernetes | Meest Kubernetes-native, autopilot mode | Google Cloud lock-in |
| **DigitalOcean DOKS** | Simpele managed Kubernetes | Goedkoop, eenvoudig, transparant | Minder enterprise features |
| **Self-Managed** | Je eigen cluster (kubeadm, Rancher) | Volledige controle, geen vendor lock-in | Meer operationele overhead |

### Laag 2: CI/CD Pipeline met GitOps 🚀

De moderne deployment flow van code naar productie:

```
📚 Git Repo → 🔨 CI Build → 📦 Registry → 🔄 GitOps Tool → 🎯 Deploy → ♻️ Sync
```

**Flow uitleg:**
1. **Git Repository** - Single source of truth voor alle configuratie
2. **CI Build** - Automated testing, linting, building, packaging
3. **Container Registry** - Opslag van container images
4. **GitOps Controller** - Synchroniseert Git → Kubernetes automatically
5. **Deployment** - Applicaties worden automatisch gedeployed
6. **Sync Monitor** - Continue monitoring en synchronisatie van desired state

**GitOps Principes:**
- Git is de single source of truth
- Declarative infrastructure as code
- Automated synchronization
- Observable deployments
- Rollback capability via Git

### Laag 3: Control Plane 🧠

De hersenen van Kubernetes - verantwoordelijk voor cluster management:

| Component | Emoji | Functie |
|-----------|-------|---------|
| **API Server** | 🌐 | Centrale toegangspunt voor alle Kubernetes API calls |
| **Scheduler** | 📅 | Bepaalt op welke node pods draaien (resource-based) |
| **Controller Manager** | 🎮 | Reconciliation loops voor desired state management |
| **Cloud Controller Manager** | ☁️ | Cloud provider specifieke integraties (LB, volumes) |
| **etcd** | 💾 | Distributed key-value store voor cluster state |
| **CoreDNS** | 🔍 | Service discovery en DNS binnen het cluster |

**In managed Kubernetes (AKS/EKS/GKE):** De control plane wordt volledig beheerd door de cloud provider. Je betaalt alleen voor de worker nodes.

### Laag 4: Ingress / Load Balancer 🌐

Externe toegang tot je cluster:

| Component | Use Case |
|-----------|----------|
| **Ingress Controller** | HTTP/HTTPS routing en path-based routing |
| **Load Balancer** | Layer 4 (TCP/UDP) traffic distribution |
| **API Gateway** | Advanced routing, rate limiting, authentication |
| **TLS/Certificate Management** | Automatische SSL/TLS certificates via protocollen zoals ACME |

### Laag 5: Worker Nodes 🖥️

Waar je workloads daadwerkelijk draaien. Elke node heeft:

**Node Componenten:**
- **Kubelet** - Agent die communiceert met control plane, beheert pods
- **Kube-proxy** - Network proxy voor service networking
- **Container Runtime** - Draait de containers (containerd, CRI-O, Docker)

**Kubernetes Objecten (workloads):**

| Object Type | Emoji | Gebruik |
|-------------|-------|---------|
| **Pod** | 📦 | Kleinste deploybare eenheid, groep van 1+ containers |
| **Deployment** | 🚀 | Voor stateless applicaties, rolling updates |
| **StatefulSet** | 💿 | Voor stateful applicaties met persistent identity |
| **DaemonSet** | ⚙️ | Draait op alle (of specifieke) nodes (monitoring, logging) |
| **Job** | 📋 | One-time tasks |
| **CronJob** | ⏰ | Scheduled recurring tasks |
| **Service** | 🔗 | Stable endpoint voor pods, load balancing |

**Configuratie & Security:**
- **ConfigMap** 📝 - Configuration data (niet-gevoelig)
- **Secret** 🔐 - Sensitive data (credentials, keys)
- **Volume (PVC)** 💾 - Persistent storage claims
- **Network Policy** 🛡️ - Traffic control tussen pods
- **RBAC** 🔐 - Role-based access control

**Autoscaling:**
- **Horizontal Pod Autoscaler (HPA)** 📊 - Scale pods based on CPU/memory/custom metrics
- **Vertical Pod Autoscaler (VPA)** - Adjust resource requests/limits
- **Cluster Autoscaler** - Add/remove nodes based on demand

### Laag 6: Service Mesh 🕸️

**Dit is het unieke van deze infographic: visualisatie waar een Service Mesh leeft!**

Een Service Mesh is een infrastructure layer die **tussen je Services** leeft en al het service-to-service verkeer onderschept.

**Wat voegt het toe:**
- ✅ **mTLS Encryption** - Automatische encryptie tussen alle services
- ✅ **Traffic Management** - Advanced load balancing, traffic splitting, canary releases
- ✅ **Circuit Breaking** - Automatic failure handling en retry logic
- ✅ **Distributed Tracing** - Request tracing door alle services
- ✅ **Metrics & Observability** - Automatische metrics zonder code wijzigingen
- ✅ **Service Discovery** - Automatische service registration

**Populaire implementaties:**
There are various service mesh solutions available, each with their own strengths in terms of complexity, performance and features.

**When do you need a Service Mesh?**
- Microservices architecture with 10+ services
- Compliance requires mTLS between all services
- Advanced traffic management needed (canary, A/B testing)
- Detailed observability between services
- Zero-trust networking within the cluster

### Laag 7: Persistent Storage 💾

Data die blijft bestaan na pod restarts:

| Component | Beschrijving |
|-----------|--------------|
| **Persistent Volume (PV)** | Cluster resource met storage capacity |
| **Persistent Volume Claim (PVC)** | Request voor storage door een pod |
| **Storage Class** | Dynamic provisioning van volumes |
| **CSI Driver** | Container Storage Interface voor cloud/NFS storage |
| **Backup Solution** | Kubernetes backup and disaster recovery tools |

**Storage Types:**
- **Block Storage** - AWS EBS, Azure Disk, GCP Persistent Disk
- **File Storage** - NFS, Azure Files, AWS EFS
- **Object Storage** - S3, Azure Blob, GCS (niet via PV/PVC)

---

## 🎯 Use Cases

### 1. Technische Training & Onboarding

**Voor nieuwe teamleden:**
- Toon hoe Kubernetes van boven naar beneden werkt
- Leg uit waar elk component leeft
- Visualiseer de deployment flow via GitOps
- Demonstreer waar een Service Mesh past in de architectuur

**Training format:**
1. Start bij Managed Kubernetes (keuze van platform)
2. Loop door de CI/CD pipeline
3. Duik in de Control Plane
4. Toon Worker Nodes met verschillende workload types
5. Leg Service Mesh uit als overlay
6. Sluit af met storage persistentie

### 2. Architectuur Reviews

**Voor architectuur discussies:**
- Gebruik om huidige vs gewenste architectuur te vergelijken
- Markeer welke componenten je al hebt vs wat nog moet komen
- Discussieer waar Service Mesh toegevoegde waarde heeft
- Plan migratie van self-managed naar managed Kubernetes

### 3. Stakeholder Presentaties

**Voor management en niet-technische stakeholders:**
- Laat zien hoe complex maar ook goed georganiseerd Kubernetes is
- Visualiseer waarom je bepaalde managed services kiest
- Toon de investment in GitOps en automation
- Leg uit waarom Service Mesh wel/niet nodig is

### 4. Documentatie & Knowledge Base

**Voor interne documentatie:**
- Embed in confluence/wiki als architectuur overzicht
- Link vanuit component documentatie naar de infographic
- Gebruik als startpunt voor nieuwe projecten
- Print als poster voor in de teamruimte

### 5. Troubleshooting & Debugging

**Voor incident response:**
- Identificeer welke laag het probleem zit
- Trace request flow van Ingress → Service → Pod
- Check Service Mesh metrics als die aanwezig is
- Identificeer storage issues in de persistence layer

### 6. Capacity Planning

**Voor scaling discussies:**
- Visualiseer hoeveel nodes en pods je hebt
- Plan HPA/VPA/Cluster Autoscaler implementatie
- Discussieer storage capacity en backup strategie
- Evalueer managed vs self-managed trade-offs

---

## 🔍 Detail Uitleg per Component

### Pods 📦

**Wat is een Pod?**
- Kleinste deploybare eenheid in Kubernetes
- Groep van 1 of meer containers
- Deelt network namespace (localhost binnen pod)
- Deelt storage volumes
- Ephemeral - kan op elk moment vervangen worden

**Pod Lifecycle:**
```
Pending → Running → Succeeded/Failed
```

**Best Practices:**
- Meestal 1 container per pod (sidecar patterns zijn uitzondering)
- Gebruik readiness/liveness probes
- Definieer resource requests & limits
- Gebruik labels voor organisatie

### Services 🔗

**Wat is een Service?**
- Stable endpoint voor een groep pods
- Load balancing tussen pods
- Service discovery via DNS
- Blijft bestaan ook als pods veranderen

**Service Types:**
- **ClusterIP** - Internal only (default)
- **NodePort** - Exposes op elke node's IP
- **LoadBalancer** - Cloud provider load balancer
- **ExternalName** - DNS CNAME mapping

### Deployments 🚀

**Wat is een Deployment?**
- Declarative management van ReplicaSets en Pods
- Rolling updates en rollbacks
- Scaling (replicas)
- Self-healing

**Deployment Strategy:**
```yaml
strategy:
  type: RollingUpdate  # of Recreate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### StatefulSets 💿

**When to use?**
- Databases (PostgreSQL, MongoDB, Cassandra)
- Message queues with persistent identity
- Applications that need persistent storage + stable network identity

**Characteristics:**
- Ordered pod creation/deletion (pod-0, pod-1, pod-2)
- Stable network identifiers
- Persistent storage per pod

### DaemonSets ⚙️

**When to use?**
- Log collectors (agent-based logging solutions)
- Monitoring agents (system metrics exporters)
- Storage daemons (distributed storage systems)
- Network plugins (CNI implementations)

**Characteristic:** Runs exactly 1 pod per node (or subset of nodes via node selector)

### Service Mesh - In Depth 🕸️

**How does it work technically?**

1. **Sidecar Proxy Pattern:**
   - Each pod gets a sidecar proxy container (e.g., Envoy)
   - All inbound/outbound traffic goes through the proxy
   - Control plane configures all proxies

2. **Data Plane vs Control Plane:**
   - **Data Plane:** Sidecar proxies (handling actual traffic)
   - **Control Plane:** Mesh controller (configuration & policy)

3. **mTLS in action:**
   ```
   Pod A → Envoy Proxy A [encrypt with mTLS] → Envoy Proxy B → Pod B
   ```

**Cost vs Benefit:**
- **Cost:** Extra resource usage (CPU/memory per sidecar), complexity, latency overhead
- **Benefit:** Security (mTLS), observability (tracing), reliability (retries, circuit breaking)

**When NOT to use:**
- Small clusters (<10 services)
- Simple architectures (monolith, few microservices)
- Resource constrained environments
- Team has no service mesh expertise

---

## 🚀 GitOps in Detail

### Wat is GitOps?

**Definitie:** Operational model waar Git de single source of truth is voor infrastructure en applicaties.

**Core Principles:**
1. **Declarative** - Desired state in Git (YAML manifests)
2. **Versioned & Immutable** - Git history = audit trail
3. **Pulled Automatically** - GitOps agent syncs Git → Cluster
4. **Continuously Reconciled** - Drift detection en auto-correction

### GitOps Tools Vergelijking

Verschillende GitOps oplossingen hebben verschillende sterke punten:

| Feature | Tool Type A (UI-focused) | Tool Type B (CLI-focused) |
|---------|--------------------------|---------------------------|
| **UI** | ✅ Excellent web UI | ❌ CLI only (maar web UI's beschikbaar) |
| **Complexity** | Medium | Simple |
| **Multi-cluster** | ✅ Native support | ✅ Via multi-tenancy patterns |
| **CNCF Status** | Graduated options available | Graduated options available |
| **Helm Support** | ✅ Excellent | ✅ Excellent |
| **Kustomize** | ✅ Built-in | ✅ Native |
| **Best For** | Teams wanting UI, multi-cluster | Pure GitOps, simple setups |

### GitOps Workflow Voorbeeld

```
1. Developer pusht code naar Git
   ↓
2. CI pipeline
   - Runs tests
   - Builds Docker image
   - Pushes to registry
   - Updates manifest in Git (image tag)
   ↓
3. GitOps controller detects change in Git
   ↓
4. Syncs new manifest to Kubernetes
   ↓
5. Kubernetes deploys new version
   ↓
6. Monitoring detects issue?
   ↓
7. Git revert = automatic rollback
```

**Voordeel:** Rollback is een `git revert`, geen kubectl commando's!

---

## 🔒 DevSecOps Pipeline - Security at Every Stage

De DevSecOps pipeline infographic visualiseert waar en wanneer security maatregelen worden toegepast in de complete pipeline van development tot runtime.

### Pipeline Stages en Security Controls

#### 1. Development Stage 👨‍💻

**Security Maatregelen:**
- **SAST (Static Application Security Testing)** - Scan source code voor security vulnerabilities
- **Linting** - Code quality en security rules enforcement
- **Secrets Detection** - Pre-commit hooks voorkomen hardcoded secrets
- **SCA (Software Composition Analysis)** - Check dependencies voor bekende CVEs

**Waarom belangrijk:** Vroeg in de pipeline gevonden vulnerabilities zijn goedkoper om te fixen.

#### 2. Build & Test Stage 🔨

**Security Maatregelen:**
- **Automated SAST** - Geautomatiseerde security scans in CI
- **Unit Tests** - Inclusief security-gerelateerde tests
- **Container Image Scanning** - CVE scanning van base images en dependencies
- **Image Signing** - Cryptografische handtekening voor image integrity
- **SBOM Generation** - Software Bill of Materials voor compliance

**Waarom belangrijk:** Voorkomt dat vulnerable images de registry bereiken.

#### 3. Registry Stage 📦

**Security Maatregelen:**
- **Access Control** - RBAC op wie wat mag pullen/pushen
- **Continuous Re-scanning** - Periodieke CVE scans van opgeslagen images
- **Signature Verification** - Alleen signed images accepteren
- **Encryption at Rest** - Images encrypted opslaan
- **Policy Enforcement** - Vulnerability thresholds en retention policies

**Waarom belangrijk:** Registry is single source of truth voor images.

#### 4. Deployment Stage 🚀

**Security Maatregelen:**
- **Admission Control** - Policy enforcement bij deployment (OPA, Kyverno, etc.)
- **Image Verification** - Verify signatures before allowing deployment
- **RBAC** - Role-Based Access Control policies
- **Network Policies** - Pod-to-pod communication restrictions
- **Pod Security Standards** - Seccomp, AppArmor, security contexts

**Waarom belangrijk:** Laatste defense line voordat code in productie draait.

#### 5. Runtime Stage 🏃

**Security Maatregelen:**
- **Runtime Security** - Real-time threat detection
- **Behavior Monitoring** - Detect abnormal container behavior
- **Anomaly Detection** - Machine learning-based threat detection
- **Incident Response** - Automated or manual threat response

**Waarom belangrijk:** Detecteert zero-day exploits en runtime attacks.

### Security Best Practices per Stage

**Shift Left Security:**
- Implementeer zo vroeg mogelijk in de pipeline
- Maak security onderdeel van development proces
- Automatiseer alle security checks

**Defense in Depth:**
- Meerdere security layers op verschillende niveaus
- Geen single point of failure in security
- Redundante controles waar kritisch

**Continuous Monitoring:**
- Security is geen one-time check
- Continue monitoring gedurende hele lifecycle
- Regular updates en re-scanning

### Compliance en Audit

De DevSecOps pipeline ondersteunt compliance requirements:
- **Traceability** - Elke image traceable naar source code commit
- **SBOM** - Complete inventory van alle componenten
- **Audit Trail** - Logging van alle security events
- **Policy as Code** - Reproducible en version-controlled policies



---

## 🛠️ Bewerken van de Infographic

### SVG Bewerkingsprogramma's

1. **Inkscape** (Gratis, Open Source)
   - Download: https://inkscape.org/
   - Beste voor Linux en open-source workflow

2. **Adobe Illustrator** (Commercieel)
   - Professionele tool
   - Volledige SVG support

3. **Figma** (Gratis/Commercieel)
   - Browser-based
   - Import SVG via File → Import

### SVG Structuur

```xml
<svg viewBox="0 0 1600 1400">
  <!-- Managed Kubernetes Layer -->
  <g id="managed-k8s" data-layer="managed">
    <g id="aks" class="domain" data-domain="aks">...</g>
    <g id="eks" class="domain" data-domain="eks">...</g>
  </g>
  
  <!-- Pipeline Layer -->
  <g id="pipeline" data-layer="pipeline">...</g>
  
  <!-- Control Plane -->
  <g id="control-plane" data-layer="control-plane">...</g>
  
  <!-- Worker Nodes -->
  <g id="node1" data-layer="node">
    <g id="pod1-1" data-domain="pod">...</g>
  </g>
  
  <!-- Service Mesh (overlay) -->
  <g id="service-mesh" data-layer="mesh">...</g>
</svg>
```

### Data Attributes voor Interactiviteit

Elk component heeft:
- `id` - Unieke identifier
- `class="domain"` - Voor CSS styling
- `data-domain` - Voor JavaScript interactie
- `data-layer` - Layer identificatie

---

## 🎓 Vergelijking: Architectuur vs Ecosysteem

### Ecosysteem Infographic (bestaand)

**Doel:** Beslissen welke domeinen te implementeren en in welke volgorde

**Structuur:**
- Laag 0 (Rood): Fundament - beslissen op dag 1
- Laag 1 (Geel): Kernfuncties - implementeren in maand 1
- Laag 2 (Groen): Verbeteringen - toevoegen wanneer nodig

**Domeinen:** Infrastructure, Security, Networking, GitOps, CI/CD, Observability, Storage, Registry, Messaging, etc.

**Voor wie:** Platform engineers, architects die een Kubernetes platform opzetten

### Architectuur Infographic (nieuw)

**Doel:** Begrijpen hoe Kubernetes technisch werkt en waar componenten leven

**Structuur:**
- Top-down: Managed K8s → Pipeline → Control Plane → Nodes → Service Mesh → Storage
- Toont echte Kubernetes objecten en hun relaties

**Componenten:** Pods, Services, Deployments, StatefulSets, Control Plane, Service Mesh, etc.

**Voor wie:** Developers, operators, iedereen die Kubernetes technisch wil begrijpen

### Gebruik Samen

1. **Start met Ecosysteem** - Begrijp welke domeinen je nodig hebt
2. **Ga naar Architectuur** - Zie hoe het technisch werkt
3. **Plan implementatie** - Gebruik beide voor complete planning

**Voorbeeld workflow:**
- Ecosysteem: "Ik heb een Service Mesh nodig (Laag 2)"
- Architectuur: "Ik zie waar de Service Mesh leeft (tussen services)"
- Implementatie: "Ik weet nu wanneer en hoe te implementeren"

---

## 🔗 Interactief Maken

### JavaScript Event Handlers

```javascript
// Load SVG
const svgObject = document.getElementById('infographic');
const svgDoc = svgObject.contentDocument;

// Add click handlers
svgDoc.querySelectorAll('.domain').forEach(domain => {
    domain.style.cursor = 'pointer';
    
    domain.addEventListener('click', () => {
        const domainName = domain.dataset.domain;
        // Show detailed info panel
        showComponentInfo(domainName);
    });
});
```

### Tooltip Functionaliteit

```javascript
// Show component details on hover
svgDoc.querySelectorAll('.domain').forEach(domain => {
    domain.addEventListener('mouseenter', (e) => {
        const info = getComponentInfo(domain.dataset.domain);
        showTooltip(e.pageX, e.pageY, info);
    });
});
```

### Layer Filtering

```javascript
// Toggle visibility per layer
function toggleLayer(layerName) {
    const layer = svgDoc.querySelector(`[data-layer="${layerName}"]`);
    const opacity = layer.getAttribute('opacity') || '1';
    layer.setAttribute('opacity', opacity === '1' ? '0.2' : '1');
}

// Buttons
<button onclick="toggleLayer('control-plane')">Toggle Control Plane</button>
<button onclick="toggleLayer('mesh')">Toggle Service Mesh</button>
```

---

## 📖 Leerpad voor Nieuwe Teamleden

### Week 1: Basis Begrip

1. **Bekijk de infographic** - Top tot bottom walkthrough
2. **Lees deze README** - Focus op "Detail Uitleg per Component"
3. **Hands-on Lab:**
   - Deploy een pod: `kubectl run nginx --image=nginx`
   - Expose via service: `kubectl expose pod nginx --port=80`
   - Check status: `kubectl get pods,services`

### Week 2: Workload Management

1. **Study Deployments, StatefulSets, DaemonSets**
2. **Hands-on Lab:**
   - Create a Deployment with 3 replicas
   - Scale up/down
   - Perform rolling update
   - Rollback

### Week 3: Networking & Services

1. **Study Services, Ingress, Network Policies**
2. **Hands-on Lab:**
   - Deploy app with ClusterIP service
   - Add Ingress for external access
   - Apply Network Policy for isolation

### Week 4: GitOps & CI/CD

1. **Study de pipeline layer in de infographic**
2. **Hands-on Lab:**
   - Setup a GitOps controller
   - Deploy app via Git
   - Make change → automatic sync
   - Practice rollback via Git

### Week 5: Advanced Topics

1. **Study Service Mesh layer**
2. **Hands-on Lab (optional):**
   - Install a service mesh in test cluster
   - Enable mTLS
   - View service mesh metrics
   - Configure traffic splitting

### Week 6: DevSecOps & Security

1. **Study DevSecOps pipeline infographic**
2. **Hands-on Lab:**
   - Implement SAST in development
   - Setup container image scanning
   - Configure admission controllers
   - Practice image signing and verification
   - Setup runtime security monitoring

---

## 🎯 Roadmap

### Q1 2026

- [x] Basis architectuur infographic met alle lagen (tool-agnostisch)
- [x] DevSecOps pipeline infographic met security stages
- [x] HTML viewer met beide infographics en uitleg
- [x] Comprehensive README documentatie
- [ ] Export naar PNG/PDF voor presentaties
- [ ] Engelse versie

### Q2 2026

- [ ] Interactieve tooltips bij hover over componenten
- [ ] Click handlers met component details
- [ ] Animated flow: request → ingress → service → pod
- [ ] Layer toggle functionaliteit (show/hide layers)

### Q3 2026

- [ ] Video walkthrough van de infographic
- [ ] Training module met quizzes
- [ ] Integration met KubeCompass documentatie
- [ ] Printable poster versie (A1 formaat)

---

## 📝 Licentie en Gebruik

Deze infographic is onderdeel van het **KubeCompass** project en valt onder de **MIT License**.

✅ **Je mag:**
- Gebruiken in presentaties en training
- Aanpassen voor je eigen organisatie
- Delen met credits naar KubeCompass
- Printen als poster
- Embedden in documentatie

❌ **Je mag niet:**
- Verkopen zonder aanpassingen
- Claims maken alsof je het origineel hebt gemaakt
- Gebruiken zonder credit als je het online deelt

**Credit:** 
```
Bron: KubeCompass - https://github.com/vanhoutenbos/KubeCompass
```

---

## 🤝 Bijdragen

Wil je de infographic verbeteren? Geweldig!

### Ideeën voor Bijdragen

1. **Verbeterde visualisaties** - Betere icons, kleuren, layout
2. **Animaties** - SVG animaties voor request flows
3. **Vertalingen** - Engels, Duits, Frans
4. **Interactieve versie** - Volledige HTML/JS implementatie
5. **Component details** - Uitgebreidere uitleg per component
6. **Use case scenarios** - Specific deployment patterns

### Hoe Bijdragen

1. Fork de repository
2. Maak je aanpassingen in `kubernetes-architecture-infographic.svg`
3. Test in `kubernetes-architecture.html`
4. Update documentatie als nodig
5. Submit een Pull Request met uitleg

---

## 📞 Contact en Feedback

- **GitHub Issues**: Voor bugs en feature requests
- **GitHub Discussions**: Voor vragen en ideeën
- **Pull Requests**: Voor concrete verbeteringen

---

## 🎨 Design Beslissingen

### Waarom Top-Down Layout?

De architectuur flow is natuurlijk top-down:
1. Je **kiest** een managed Kubernetes provider (top)
2. Je **bouwt** een CI/CD pipeline
3. Het **draait** op control plane + worker nodes
4. Je **voegt toe** service mesh als nodig
5. Je **persisteert** data in storage (bottom)

### Waarom Service Mesh als Overlay?

Een Service Mesh is geen aparte laag maar een **overlay network** die tussen services leeft. De semi-transparante styling en dashed border visualiseren dat het "bovenop" het cluster ligt en verkeer onderschept.

### Why Managed K8s at the Top?

For most teams, "where do I get my cluster from" is the first decision. Managed vs self-managed has a major impact on the rest of the architecture (control plane visibility, upgrade management, cloud integrations).

### Color Scheme Rationale

- **Blue** (Control Plane) - Reliable, stable, "brain"
- **Groen** (Worker Nodes) - Groeiend, scaling, "workhorses"
- **Oranje** (Service Mesh) - Overlay, warning (adds complexity)
- **Paars** (Pipeline) - Automation, modern tooling
- **Goud** (Storage) - Valuable, persistent data
- **Rood** (Ingress) - Entry point, attention-grabbing

---

**Veel succes met het gebruik van de architectuur infographic! ⚙️**

Voor vragen of suggesties, open een issue of discussion in de [KubeCompass repository](https://github.com/vanhoutenbos/KubeCompass).
