# Tests

Test suites for validating cluster functionality and platform concepts.

## Structure

```
tests/
  ├── smoke/     # Basic cluster validation
  ├── policy/    # Policy engine testing (Kyverno/OPA)
  └── chaos/     # Chaos engineering tests
```

## Test Categories

### Smoke Tests
**Purpose**: Validate basic cluster health
**When**: After every cluster creation
**Duration**: < 1 minute

See: [smoke/README.md](smoke/README.md)

### Policy Tests
**Purpose**: Validate security and operational policies
**When**: Before deploying workloads
**Duration**: 2-5 minutes

Coming soon.

### Chaos Tests
**Purpose**: Validate resilience and recovery
**When**: Platform validation phase
**Duration**: 5-15 minutes

Coming soon.

## Testing Philosophy

This is a **validation platform**, not a production system.

Tests should:
- Validate concepts, not implementations
- Be reproducible across environments
- Have clear pass/fail criteria
- Document expected behavior
- Be automatable

Tests should NOT:
- Require cloud services
- Depend on external APIs
- Take more than 15 minutes
- Leave resources behind
- Assume production constraints

## Running Tests

### Quick validation
```bash
# Windows
.\tests\smoke\run-tests.ps1

# Linux
./tests/smoke/run-tests.sh
```

### Against specific cluster
```bash
# Windows
.\tests\smoke\run-tests.ps1 -Context kind-kubecompass-cilium

# Linux
./tests/smoke/run-tests.sh kind-kubecompass-calico
```

## Test Development

New tests should:
1. Have a README
2. Be idempotent
3. Clean up after themselves
4. Support multiple clusters
5. Output structured results

## Integration

Tests can be run in CI/CD:

```yaml
# GitHub Actions example
- name: Create cluster
  run: ./kind/create-cluster.sh base

- name: Run smoke tests
  run: ./tests/smoke/run-tests.sh

- name: Deploy workloads
  run: kubectl apply -f manifests/

- name: Run integration tests
  run: ./tests/integration/run-tests.sh
```

## Future Tests

- [ ] Network policy validation
- [ ] RBAC policy validation
- [ ] Resource quota enforcement
- [ ] Pod security standards
- [ ] Chaos scenarios (pod deletion, network partition)
- [ ] GitOps sync validation
- [ ] Observability stack validation
