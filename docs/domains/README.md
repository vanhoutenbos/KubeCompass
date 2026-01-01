# Domain Documentation

Deze directory bevat diepgaande documentatie voor elk Kubernetes platform domein, georganiseerd per Layer.

---

## Structuur

```
domains/
├── 00-foundations/     # Layer 0 - Foundational (Day 1 decisions)
├── 01-operations/      # Layer 1 - Core Operations (First month)
├── 02-enhancements/    # Layer 2 - Enhancements (Add when needed)
└── DOMAIN_TESTING_TEMPLATE.md  # Template voor nieuwe domeinen
```

---

## Layer 0: Foundations (00-foundations/)

**Decision Timing**: Day 1  
**Migration Cost**: HIGH  
**Impact**: Architecturally significant

Domeinen die je vanaf het begin goed moet hebben, omdat ze moeilijk te veranderen zijn later:

1. **CNI (Container Network Interface)** - Hoe pods communiceren
2. **GitOps Strategy** - Hoe je deployment workflow werkt
3. **RBAC & Identity** - Wie heeft toegang tot wat
4. **Secrets Management** - Hoe je gevoelige data beheert
5. **Infrastructure as Code** - Hoe je clusters provisioneert
6. **Network Policies** - Hoe je network traffic isoleert

---

## Layer 1: Core Operations (01-operations/)

**Decision Timing**: Within first month  
**Migration Cost**: MEDIUM  
**Impact**: Significant but changeable

Domeinen die essentieel zijn voor productie, maar met matige effort vervangbaar:

1. **Observability** - Metrics, logging, tracing
2. **Container Registry** - Image storage en management
3. **Disaster Recovery** - Backup en business continuity
4. **Data Persistence** - Storage en databases
5. **CI/CD Pipeline** - Build en deployment automation
6. **Ingress & Load Balancing** - Traffic routing naar services

---

## Layer 2: Enhancements (02-enhancements/)

**Decision Timing**: Add when needed  
**Migration Cost**: LOW  
**Impact**: Plug-and-play, easy to add/remove

Domeinen die je later kan toevoegen zonder grote impact:

1. **Runtime Security** - Threat detection (Falco, Tetragon)
2. **Service Mesh** - Advanced traffic management
3. **Policy & Governance** - OPA, Kyverno voor compliance
4. **Cost Management** - FinOps tooling
5. **Multi-Cluster Management** - Federation en centralized control

---

## Hoe een nieuw domein documenteren

1. **Kopieer de template**: [DOMAIN_TESTING_TEMPLATE.md](DOMAIN_TESTING_TEMPLATE.md)
2. **Volg de testing workflow** in de template
3. **Vul alle secties in** met praktische bevindingen
4. **Test minimaal 2 tools** per domein
5. **Definieer "Choose X unless Y"** beslisregel
6. **Test op meerdere providers** waar relevant
7. **Peer review** voordat je het markeert als complete

---

## Domein Status Tracking

Zie [DOMAIN_COVERAGE_MASTER.md](../DOMAIN_COVERAGE_MASTER.md) voor volledig overzicht van:
- Welke domeinen zijn getest
- Welke tools zijn vergeleken
- Wat zijn de beslisregels
- Wat ontbreekt nog

---

## Quality Standards

Elk domein document moet:
- ✅ Minimaal 2 tools praktisch getest
- ✅ "Choose X unless Y" beslisregel gedefinieerd
- ✅ Security checklist ingevuld
- ✅ Provider portability matrix compleet
- ✅ Praktische voorbeelden (geen theorie)
- ✅ Migration strategies gedocumenteerd
- ✅ Tool-agnostische principles eerst
- ✅ Geen vendor bias zonder technische onderbouwing

---

## Bijdragen

Wil je een domein testen en documenteren?

1. Kies een domein uit [DOMAIN_COVERAGE_MASTER.md](../DOMAIN_COVERAGE_MASTER.md)
2. Claim het door een issue aan te maken
3. Gebruik de [DOMAIN_TESTING_TEMPLATE.md](DOMAIN_TESTING_TEMPLATE.md)
4. Open een PR met je bevindingen
5. Vraag review van maintainers

Zie [CONTRIBUTING.md](../../CONTRIBUTING.md) voor meer details.
