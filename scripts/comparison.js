// ==========================================================================
// Comparison Page JavaScript
// ==========================================================================

document.addEventListener('DOMContentLoaded', function() {
    // Mobile Navigation Toggle
    initMobileNav();
    
    // Smooth Scroll for Anchor Links
    initSmoothScroll();
    
    // Feedback System
    initFeedbackSystem();
    
    // Tool Card Animations
    initToolCardAnimations();
});

// Mobile Navigation
function initMobileNav() {
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            
            // Animate hamburger icon
            const spans = this.querySelectorAll('span');
            if (navMenu.classList.contains('active')) {
                spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
                spans[1].style.opacity = '0';
                spans[2].style.transform = 'rotate(-45deg) translate(7px, -6px)';
            } else {
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            }
        });
        
        // Close menu when clicking on a link
        const navLinks = navMenu.querySelectorAll('a');
        navLinks.forEach(link => {
            link.addEventListener('click', function() {
                navMenu.classList.remove('active');
                const spans = navToggle.querySelectorAll('span');
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            });
        });
    }
}

// Smooth Scroll
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            
            // Skip if it's just "#"
            if (href === '#') return;
            
            e.preventDefault();
            
            const target = document.querySelector(href);
            if (target) {
                const offsetTop = target.offsetTop - 80; // Account for sticky nav
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// Feedback System
function initFeedbackSystem() {
    const feedbackButtons = document.querySelectorAll('.btn-feedback');
    const feedbackForm = document.getElementById('feedbackForm');
    
    feedbackButtons.forEach(button => {
        button.addEventListener('click', function() {
            const feedback = this.dataset.feedback;
            
            // Show thank you message
            if (feedback === 'positive') {
                showNotification('Thank you! Your feedback helps improve KubeCompass.', 'success');
            } else {
                // Show feedback form for negative feedback
                if (feedbackForm) {
                    feedbackForm.style.display = 'block';
                    feedbackForm.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
            
            // Track feedback (analytics placeholder)
            trackFeedback(feedback, window.location.pathname);
        });
    });
    
    // Submit feedback form
    if (feedbackForm) {
        const submitButton = feedbackForm.querySelector('button');
        if (submitButton) {
            submitButton.addEventListener('click', function() {
                const textarea = feedbackForm.querySelector('textarea');
                const feedbackText = textarea.value.trim();
                
                if (feedbackText) {
                    showNotification('Thank you for your detailed feedback!', 'success');
                    feedbackForm.style.display = 'none';
                    textarea.value = '';
                    
                    // Track detailed feedback (analytics placeholder)
                    trackDetailedFeedback(feedbackText, window.location.pathname);
                }
            });
        }
    }
}

// Tool Card Animations
function initToolCardAnimations() {
    const cards = document.querySelectorAll('.tool-card');
    
    const observerOptions = {
        threshold: 0.2,
        rootMargin: '0px 0px -100px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '0';
                entry.target.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    entry.target.style.transition = 'all 0.6s ease';
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, 100);
                
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    cards.forEach(card => {
        observer.observe(card);
    });
}

// Notification System
function showNotification(message, type = 'info') {
    // Remove existing notification
    const existing = document.querySelector('.notification');
    if (existing) {
        existing.remove();
    }
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Add styles
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        padding: '1rem 1.5rem',
        borderRadius: '8px',
        background: type === 'success' ? '#48bb78' : '#667eea',
        color: 'white',
        boxShadow: '0 10px 30px rgba(0, 0, 0, 0.2)',
        zIndex: '9999',
        animation: 'slideIn 0.3s ease',
        maxWidth: '400px',
        fontSize: '1rem',
        fontWeight: '500'
    });
    
    document.body.appendChild(notification);
    
    // Auto-remove after 4 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 4000);
}

// Analytics Placeholders (Replace with actual analytics)
function trackFeedback(feedback, page) {
    console.log('Feedback tracked:', { feedback, page, timestamp: new Date().toISOString() });
    
    // Google Analytics example:
    // gtag('event', 'feedback', {
    //     'event_category': 'engagement',
    //     'event_label': feedback,
    //     'value': feedback === 'positive' ? 1 : 0
    // });
}

function trackDetailedFeedback(text, page) {
    console.log('Detailed feedback tracked:', { text, page, timestamp: new Date().toISOString() });
    
    // Could send to backend API:
    // fetch('/api/feedback', {
    //     method: 'POST',
    //     headers: { 'Content-Type': 'application/json' },
    //     body: JSON.stringify({ text, page, timestamp: new Date().toISOString() })
    // });
}

// CSS Animations (injected dynamically)
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateX(100px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    @keyframes slideOut {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(100px);
        }
    }
`;
document.head.appendChild(style);
