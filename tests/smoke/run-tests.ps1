#!/usr/bin/env pwsh
# Smoke Test Suite for Kind Cluster
# Validates basic cluster functionality

param(
    [Parameter(Mandatory=$false)]
    [string]$Context = ""
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Info { Write-Host "→ $args" -ForegroundColor Cyan }
function Write-Failure { Write-Host "✗ $args" -ForegroundColor Red }
function Write-Test { Write-Host "TEST: $args" -ForegroundColor Yellow }

Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host "  KubeCompass - Smoke Test Suite" -ForegroundColor Blue
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host ""

# Set context if provided
if ($Context) {
    kubectl config use-context $Context | Out-Null
    Write-Info "Using context: $Context"
}

$CurrentContext = kubectl config current-context
Write-Info "Current context: $CurrentContext"
Write-Host ""

$TestsPassed = 0
$TestsFailed = 0

# Test 1: Cluster connectivity
Write-Test "1. Cluster API connectivity"
try {
    kubectl cluster-info | Out-Null
    Write-Success "Cluster API is reachable"
    $TestsPassed++
} catch {
    Write-Failure "Cannot reach cluster API"
    $TestsFailed++
}

# Test 2: Nodes are ready
Write-Test "2. Node readiness"
try {
    $nodes = kubectl get nodes -o json | ConvertFrom-Json
    $readyNodes = $nodes.items | Where-Object { 
        $_.status.conditions | Where-Object { $_.type -eq "Ready" -and $_.status -eq "True" }
    }
    
    if ($readyNodes.Count -eq $nodes.items.Count) {
        Write-Success "All $($nodes.items.Count) node(s) are ready"
        $TestsPassed++
    } else {
        Write-Failure "Only $($readyNodes.Count) of $($nodes.items.Count) nodes are ready"
        $TestsFailed++
    }
} catch {
    Write-Failure "Failed to check node status"
    $TestsFailed++
}

# Test 3: System pods running
Write-Test "3. System pods health"
try {
    $systemPods = kubectl get pods -n kube-system -o json | ConvertFrom-Json
    $runningPods = $systemPods.items | Where-Object { $_.status.phase -eq "Running" }
    
    if ($runningPods.Count -eq $systemPods.items.Count) {
        Write-Success "All $($systemPods.items.Count) system pods are running"
        $TestsPassed++
    } else {
        Write-Failure "Only $($runningPods.Count) of $($systemPods.items.Count) system pods are running"
        $TestsFailed++
    }
} catch {
    Write-Failure "Failed to check system pods"
    $TestsFailed++
}

# Test 4: DNS resolution
Write-Test "4. DNS resolution"
try {
    kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default 2>&1 | Out-Null
    Write-Success "DNS resolution works"
    $TestsPassed++
} catch {
    Write-Failure "DNS resolution failed"
    $TestsFailed++
}

# Test 5: Create namespace
Write-Test "5. Namespace creation"
try {
    kubectl create namespace smoke-test 2>&1 | Out-Null
    Write-Success "Namespace creation successful"
    $TestsPassed++
    
    # Cleanup
    kubectl delete namespace smoke-test 2>&1 | Out-Null
} catch {
    Write-Failure "Namespace creation failed"
    $TestsFailed++
}

# Test 6: Deploy test pod
Write-Test "6. Pod deployment"
try {
    kubectl run smoke-test-pod --image=nginx:alpine --restart=Never -n default 2>&1 | Out-Null
    Start-Sleep -Seconds 10
    
    $podStatus = kubectl get pod smoke-test-pod -n default -o jsonpath='{.status.phase}'
    if ($podStatus -eq "Running") {
        Write-Success "Pod deployment successful"
        $TestsPassed++
    } else {
        Write-Failure "Pod is not running (status: $podStatus)"
        $TestsFailed++
    }
    
    # Cleanup
    kubectl delete pod smoke-test-pod -n default 2>&1 | Out-Null
} catch {
    Write-Failure "Pod deployment failed"
    $TestsFailed++
}

# Test 7: Service creation
Write-Test "7. Service creation"
try {
    kubectl create service clusterip smoke-test-svc --tcp=80:80 -n default 2>&1 | Out-Null
    Write-Success "Service creation successful"
    $TestsPassed++
    
    # Cleanup
    kubectl delete service smoke-test-svc -n default 2>&1 | Out-Null
} catch {
    Write-Failure "Service creation failed"
    $TestsFailed++
}

# Results
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host "  Test Results" -ForegroundColor Blue
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host ""

$TotalTests = $TestsPassed + $TestsFailed
Write-Host "Total tests: $TotalTests" -ForegroundColor White
Write-Host "Passed:      $TestsPassed" -ForegroundColor Green
Write-Host "Failed:      $TestsFailed" -ForegroundColor Red
Write-Host ""

if ($TestsFailed -eq 0) {
    Write-Success "All tests passed! Cluster is operational."
    exit 0
} else {
    Write-Failure "Some tests failed. Please investigate."
    exit 1
}
