// ==========================================================================
// Decision Wizard JavaScript
// ==========================================================================

document.addEventListener('DOMContentLoaded', function() {
    initWizard();
});

function initWizard() {
    const form = document.getElementById('wizardForm');
    if (!form) return;
    
    const questions = document.querySelectorAll('.wizard-question');
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    const submitBtn = document.getElementById('submitBtn');
    const resultsDiv = document.getElementById('wizardResults');
    
    let currentQuestion = 0;
    const totalQuestions = questions.length;
    
    // Initialize first question
    showQuestion(currentQuestion);
    
    // Next button
    nextBtn.addEventListener('click', function() {
        if (validateCurrentQuestion()) {
            currentQuestion++;
            showQuestion(currentQuestion);
        }
    });
    
    // Previous button
    prevBtn.addEventListener('click', function() {
        currentQuestion--;
        showQuestion(currentQuestion);
    });
    
    // Form submission
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (validateCurrentQuestion()) {
            const formData = new FormData(form);
            const answers = {
                teamSize: formData.get('teamSize'),
                needsUI: formData.get('needsUI'),
                multiCluster: formData.get('multiCluster'),
                rbac: formData.get('rbac')
            };
            
            const recommendation = calculateRecommendation(answers);
            displayRecommendation(recommendation);
            
            // Track wizard completion
            trackWizardCompletion(answers, recommendation);
        }
    });
    
    function showQuestion(index) {
        // Hide all questions
        questions.forEach(q => q.classList.remove('active'));
        
        // Show current question
        questions[index].classList.add('active');
        
        // Update navigation buttons
        if (index === 0) {
            prevBtn.style.display = 'none';
        } else {
            prevBtn.style.display = 'inline-block';
        }
        
        if (index === totalQuestions - 1) {
            nextBtn.style.display = 'none';
            submitBtn.style.display = 'inline-block';
        } else {
            nextBtn.style.display = 'inline-block';
            submitBtn.style.display = 'none';
        }
        
        // Scroll to wizard
        const wizardContainer = document.querySelector('.wizard-container');
        if (wizardContainer) {
            wizardContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    }
    
    function validateCurrentQuestion() {
        const currentQ = questions[currentQuestion];
        const inputs = currentQ.querySelectorAll('input[type="radio"]');
        const isAnswered = Array.from(inputs).some(input => input.checked);
        
        if (!isAnswered) {
            showNotification('Please select an option to continue', 'warning');
            return false;
        }
        
        return true;
    }
    
    function calculateRecommendation(answers) {
        let argoCDScore = 0;
        let fluxScore = 0;
        const reasons = {
            argocd: [],
            flux: []
        };
        
        // Team Size
        if (answers.teamSize === 'small') {
            fluxScore += 2;
            reasons.flux.push('Small team (1-5 people) - Flux is simpler to manage');
        } else if (answers.teamSize === 'medium') {
            argoCDScore += 1;
            fluxScore += 1;
            reasons.argocd.push('Medium team (5-20) - ArgoCD scales well');
            reasons.flux.push('Medium team (5-20) - Flux works great too');
        } else {
            argoCDScore += 3;
            reasons.argocd.push('Large team (20+) - ArgoCD provides better RBAC and UI for collaboration');
        }
        
        // Needs UI
        if (answers.needsUI === 'yes') {
            argoCDScore += 4;
            reasons.argocd.push('Web UI required - ArgoCD has rich, feature-complete UI');
        } else if (answers.needsUI === 'nice') {
            argoCDScore += 2;
            reasons.argocd.push('UI nice to have - ArgoCD provides visualization benefits');
        } else {
            fluxScore += 2;
            reasons.flux.push('CLI-first workflow - Flux is designed for CLI users');
        }
        
        // Multi-cluster
        if (answers.multiCluster === 'critical') {
            argoCDScore += 4;
            reasons.argocd.push('Multi-cluster critical (5+) - ArgoCD excels at managing many clusters');
        } else if (answers.multiCluster === 'some') {
            argoCDScore += 2;
            reasons.argocd.push('Multi-cluster (2-4) - ArgoCD makes this straightforward');
        } else {
            fluxScore += 1;
            reasons.flux.push('Single cluster - Flux is lightweight and sufficient');
        }
        
        // RBAC
        if (answers.rbac === 'granular') {
            argoCDScore += 3;
            reasons.argocd.push('Granular RBAC needed - ArgoCD provides per-app access control');
        } else if (answers.rbac === 'basic') {
            fluxScore += 1;
            reasons.flux.push('Basic RBAC sufficient - Flux namespace-level control works');
        } else {
            fluxScore += 1;
            reasons.flux.push('RBAC not critical - Flux simplicity is advantageous');
        }
        
        // Determine winner
        const winner = argoCDScore > fluxScore ? 'argocd' : 'flux';
        const confidence = Math.abs(argoCDScore - fluxScore) > 4 ? 'high' : 
                          Math.abs(argoCDScore - fluxScore) > 2 ? 'medium' : 'low';
        
        return {
            winner,
            confidence,
            scores: {
                argocd: argoCDScore,
                flux: fluxScore
            },
            reasons,
            answers
        };
    }
    
    function displayRecommendation(rec) {
        const contentDiv = document.getElementById('recommendationContent');
        
        const toolName = rec.winner === 'argocd' ? 'ArgoCD' : 'Flux';
        const toolScore = rec.winner === 'argocd' ? '4.2/5' : '4.0/5';
        const toolIcon = rec.winner === 'argocd' ? '🏆' : '✅';
        const altTool = rec.winner === 'argocd' ? 'Flux' : 'ArgoCD';
        
        const confidenceText = rec.confidence === 'high' ? 'Strong recommendation' :
                                rec.confidence === 'medium' ? 'Good fit' : 'Both tools viable';
        
        const confidenceClass = rec.confidence === 'high' ? 'confidence-high' :
                                 rec.confidence === 'medium' ? 'confidence-medium' : 'confidence-low';
        
        let html = `
            <div class="recommendation-result">
                <div class="recommendation-header">
                    <h2>${toolIcon} We recommend: <strong>${toolName}</strong></h2>
                    <div class="confidence-badge ${confidenceClass}">${confidenceText}</div>
                    <p class="recommendation-score">KubeCompass Score: <strong>${toolScore}</strong></p>
                </div>
                
                <div class="recommendation-reasons">
                    <h3>Why ${toolName}?</h3>
                    <ul>
                        ${rec.reasons[rec.winner].map(reason => `<li>✅ ${reason}</li>`).join('')}
                    </ul>
                </div>
                
                <div class="recommendation-comparison">
                    <h3>Score Breakdown</h3>
                    <div class="score-bars">
                        <div class="score-bar">
                            <span class="score-label">ArgoCD</span>
                            <div class="score-bar-fill" style="width: ${(rec.scores.argocd / 15) * 100}%">
                                ${rec.scores.argocd} points
                            </div>
                        </div>
                        <div class="score-bar">
                            <span class="score-label">Flux</span>
                            <div class="score-bar-fill" style="width: ${(rec.scores.flux / 15) * 100}%">
                                ${rec.scores.flux} points
                            </div>
                        </div>
                    </div>
                </div>
                
                ${rec.confidence === 'low' ? `
                <div class="recommendation-note">
                    <h3>⚖️ Close Decision</h3>
                    <p>Both tools are viable for your use case. Consider these additional factors:</p>
                    <ul>
                        <li>Team's preference for UI vs CLI workflows</li>
                        <li>Existing GitOps experience in the team</li>
                        <li>Future multi-cluster plans</li>
                    </ul>
                    <p><a href="#comparison">Review detailed comparison →</a></p>
                </div>
                ` : ''}
                
                <div class="recommendation-actions">
                    <h3>Next Steps</h3>
                    <div class="action-buttons">
                        ${rec.winner === 'argocd' ? `
                            <a href="../docs/ARGOCD_GUIDE.md" class="btn btn-primary">
                                📖 Read ArgoCD Implementation Guide
                            </a>
                            <a href="../manifests/gitops/argocd.yaml" class="btn btn-secondary">
                                📁 Get ArgoCD YAML
                            </a>
                            <a href="#flux" class="btn btn-ghost">
                                Compare with Flux
                            </a>
                        ` : `
                            <a href="../docs/FLUX_GUIDE.md" class="btn btn-primary">
                                📖 Read Flux Implementation Guide
                            </a>
                            <a href="../manifests/gitops/flux.yaml" class="btn btn-secondary">
                                📁 Get Flux YAML
                            </a>
                            <a href="#argocd" class="btn btn-ghost">
                                Compare with ArgoCD
                            </a>
                        `}
                    </div>
                </div>
                
                <div class="recommendation-footer">
                    <button class="btn btn-ghost" onclick="location.reload()">
                        🔄 Start Over
                    </button>
                </div>
            </div>
        `;
        
        contentDiv.innerHTML = html;
        resultsDiv.style.display = 'block';
        form.style.display = 'none';
        
        // Scroll to results
        resultsDiv.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

// Track wizard completion (analytics placeholder)
function trackWizardCompletion(answers, recommendation) {
    console.log('Wizard completed:', {
        answers,
        recommendation: recommendation.winner,
        confidence: recommendation.confidence,
        timestamp: new Date().toISOString()
    });
    
    // Google Analytics example:
    // gtag('event', 'wizard_complete', {
    //     'event_category': 'engagement',
    //     'event_label': recommendation.winner,
    //     'value': recommendation.confidence === 'high' ? 1 : 0
    // });
}

// Show notification (reuse from comparison.js)
function showNotification(message, type = 'info') {
    const existing = document.querySelector('.notification');
    if (existing) existing.remove();
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        padding: '1rem 1.5rem',
        borderRadius: '8px',
        background: type === 'warning' ? '#ed8936' : type === 'success' ? '#48bb78' : '#667eea',
        color: 'white',
        boxShadow: '0 10px 30px rgba(0, 0, 0, 0.2)',
        zIndex: '9999',
        animation: 'slideIn 0.3s ease',
        maxWidth: '400px',
        fontSize: '1rem',
        fontWeight: '500'
    });
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 4000);
}

// Additional CSS for recommendation display
const style = document.createElement('style');
style.textContent = `
    .recommendation-result {
        text-align: left;
    }
    
    .recommendation-header {
        text-align: center;
        margin-bottom: 2rem;
        padding-bottom: 2rem;
        border-bottom: 2px solid #e2e8f0;
    }
    
    .recommendation-header h2 {
        font-size: 2rem;
        margin-bottom: 1rem;
        color: #1a202c;
    }
    
    .recommendation-header h2 strong {
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .confidence-badge {
        display: inline-block;
        padding: 0.5rem 1rem;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin: 1rem 0;
    }
    
    .confidence-high {
        background: linear-gradient(135deg, #48bb78, #38a169);
        color: white;
    }
    
    .confidence-medium {
        background: linear-gradient(135deg, #4299e1, #3182ce);
        color: white;
    }
    
    .confidence-low {
        background: linear-gradient(135deg, #ed8936, #dd6b20);
        color: white;
    }
    
    .recommendation-score {
        font-size: 1.125rem;
        color: #4a5568;
    }
    
    .recommendation-reasons {
        margin-bottom: 2rem;
    }
    
    .recommendation-reasons h3 {
        font-size: 1.5rem;
        margin-bottom: 1rem;
        color: #1a202c;
    }
    
    .recommendation-reasons ul {
        list-style: none;
        padding: 0;
    }
    
    .recommendation-reasons ul li {
        padding: 0.75rem;
        margin-bottom: 0.5rem;
        background: #f0fff4;
        border-left: 4px solid #48bb78;
        border-radius: 4px;
        font-size: 1rem;
        line-height: 1.6;
    }
    
    .recommendation-comparison {
        margin-bottom: 2rem;
        padding: 1.5rem;
        background: #f7fafc;
        border-radius: 12px;
    }
    
    .recommendation-comparison h3 {
        font-size: 1.25rem;
        margin-bottom: 1rem;
        color: #1a202c;
    }
    
    .score-bars {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }
    
    .score-bar {
        display: flex;
        align-items: center;
        gap: 1rem;
    }
    
    .score-label {
        min-width: 80px;
        font-weight: 600;
        color: #4a5568;
    }
    
    .score-bar-fill {
        flex: 1;
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        padding: 0.5rem 1rem;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        text-align: right;
        transition: width 0.6s ease;
    }
    
    .recommendation-note {
        margin-bottom: 2rem;
        padding: 1.5rem;
        background: #fffbeb;
        border-left: 4px solid #ed8936;
        border-radius: 4px;
    }
    
    .recommendation-note h3 {
        font-size: 1.25rem;
        margin-bottom: 0.75rem;
        color: #1a202c;
    }
    
    .recommendation-note ul {
        margin: 1rem 0;
        padding-left: 1.5rem;
    }
    
    .recommendation-note ul li {
        margin-bottom: 0.5rem;
        color: #4a5568;
    }
    
    .recommendation-actions {
        margin-bottom: 2rem;
    }
    
    .recommendation-actions h3 {
        font-size: 1.5rem;
        margin-bottom: 1.5rem;
        color: #1a202c;
    }
    
    .action-buttons {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }
    
    .recommendation-footer {
        text-align: center;
        padding-top: 2rem;
        border-top: 1px solid #e2e8f0;
    }
    
    @media (max-width: 768px) {
        .score-bar {
            flex-direction: column;
            align-items: flex-start;
        }
        
        .score-bar-fill {
            width: 100% !important;
            text-align: center;
        }
    }
`;
document.head.appendChild(style);
