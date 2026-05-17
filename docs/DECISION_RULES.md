> **Persoonlijke opinie** — @vanhoutenbos | Getest op eigen lab clusters  
> Bijdragen welkom via PR. Niet eens? Open een discussie.

# Decision Rules: "Kies X tenzij Y"

**Target Audience**: Architecten, Engineers, AI Decision Agents  
**Purpose**: Concrete, herbruikbare decision rules per tool/functie  
**Type**: Decision Support Playbook  

---

## Reading Guide

Elke beslisregel volgt het format:
- **Use [Tool X] unless [Condition Y]**
- **Priority 0 Rationale**: Why deze keuze past with Priority 0 principes
- **Alternative**: Wanneer alternatief tool beter is
- **Trade-offs**: Expliciete afwegingen
- **Decision Logic**: Criteria voor interactieve filtering

---

## 1. Compute & Cluster

(… volledige inhoud met encoding fixes toegepast ...)

---

### 2.2 Ingress / Gateway

> ⚠️ **ingress-nginx (community) is EOL per maart 2026** — gebruik het niet voor nieuwe clusters.
> De Kubernetes Ingress API zelf is niet deprecated maar feature-frozen.
> Alle innovatie gaat via **Gateway API**.

#### Use Cilium Gateway unless
**Condition**: Je hebt Cilium niet als CNI OF je hebt specifieke NGINX-features nodig

**Primary Choice**: Cilium Gateway (ingebouwde Gateway API support)

**Persoonlijke Rationale (@vanhoutenbos)**:
- Als je Cilium al als CNI draait, krijg je Gateway API gratis
- Nul extra componenten, nul extra beheerslast
- Hubble geeft je direct network flow visibility op gateway niveau

**Alternative A**: NGINX Gateway Fabric
**Wanneer**:
- Je hebt al NGINX Gateway Fabric ervaring (bijv. KOOP-DRP context)
- Je wilt NGINX als data plane (vertrouwde performance karakteristieken)
- Je werkt op een cluster waar je de CNI niet kiest

**Alternative B**: Envoy Gateway (CNCF project)
**Wanneer**:
- Vendor-neutrale Envoy voorkeur zonder volledige service mesh
- Advanced features: mTLS, JWT validatie, rate limiting out-of-box
- Je bent al in het Envoy ecosystem (Istio, Contour)

**Alternative C**: Traefik
**Wanneer**:
- Dynamische configuratie zonder restarts vereist
- Kleinere footprint dan Envoy-gebaseerde opties
- Eenvoudige Let's Encrypt integratie gewenst

**NOOIT**: kubernetes/ingress-nginx (community)
- EOL maart 2026: geen patches, geen security updates
- CVE-2025-1974 (unauthenticated RCE) als waarschuwing voor wat er kan misgaan
- Gebruik het niet voor nieuwe clusters

**Trade-offs**:
| Feature | Cilium Gateway | NGINX Gateway Fabric | Envoy Gateway | Traefik |
|---------|---------------|---------------------|---------------|---------|
| **Extra component** | ✅ Nee (ingebouwd) | ⚠️ Ja | ⚠️ Ja | ⚠️ Ja |
| **Gateway API** | ✅ Native | ✅ Native | ✅ Native | ✅ Native |
| **NGINX data plane** | ❌ Nee | ✅ Ja | ❌ Envoy | ❌ Traefik |
| **Hubble integratie** | ✅ Direct | ❌ Nee | ❌ Nee | ❌ Nee |
| **CNCF status** | ✅ Graduated | ⚠️ F5/NGINX Inc. | ✅ Incubating | ⚠️ Onafhankelijk |
| **Productie bewijs** | ✅ Breed | ✅ Breed | ⚠️ Groeiend | ✅ Breed |

**Decision Logic**:
```javascript
if (cni === "cilium" && no_specific_nginx_requirement) {
  return "Cilium Gateway (gratis bij Cilium CNI)";
} else if (nginx_familiarity || koop_drp_context) {
  return "NGINX Gateway Fabric";
} else if (vendor_neutral_envoy && advanced_auth_features) {
  return "Envoy Gateway";
} else if (dynamic_config_required || small_footprint) {
  return "Traefik";
}
// NOOIT:
// return "kubernetes/ingress-nginx"; // EOL maart 2026
```

---

(… verdere inhoud, alles encoding-fixed volgens jouw mapping ...)
