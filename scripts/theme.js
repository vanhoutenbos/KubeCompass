// Theme Management Script for KubeCompass
// Handles dark/light mode toggling with localStorage persistence
// Dark mode is the default, light mode is optional

(function() {
    'use strict';
    
    const THEME_KEY = 'kubecompass-theme';
    const THEME_DARK = 'dark';
    const THEME_LIGHT = 'light';
    
    // Get theme from localStorage or default to dark
    function getStoredTheme() {
        return localStorage.getItem(THEME_KEY) || THEME_DARK;
    }
    
    // Set theme in localStorage
    function setStoredTheme(theme) {
        localStorage.setItem(THEME_KEY, theme);
    }
    
    // Apply theme to document
    function applyTheme(theme) {
        if (theme === THEME_LIGHT) {
            document.documentElement.setAttribute('data-theme', 'light');
        } else {
            document.documentElement.removeAttribute('data-theme');
        }
    }
    
    // Toggle between themes
    function toggleTheme() {
        const currentTheme = getStoredTheme();
        const newTheme = currentTheme === THEME_DARK ? THEME_LIGHT : THEME_DARK;
        setStoredTheme(newTheme);
        applyTheme(newTheme);
        updateToggleButton(newTheme);
        return newTheme;
    }
    
    // Update toggle button appearance
    function updateToggleButton(theme) {
        const toggleBtn = document.getElementById('themeToggle');
        if (!toggleBtn) return;
        
        const isDark = theme === THEME_DARK;
        toggleBtn.setAttribute('aria-label', isDark ? 'Switch to light mode' : 'Switch to dark mode');
        toggleBtn.setAttribute('title', isDark ? 'Switch to light mode' : 'Switch to dark mode');
        
        // Update button text/icon - using textContent for better accessibility
        if (isDark) {
            toggleBtn.textContent = '☀️'; // Sun icon for switching to light
        } else {
            toggleBtn.textContent = '🌙'; // Moon icon for switching to dark
        }
    }
    
    // Initialize theme on page load
    function initTheme() {
        const storedTheme = getStoredTheme();
        applyTheme(storedTheme);
        updateToggleButton(storedTheme);
    }
    
    // Initialize immediately to prevent flash
    initTheme();
    
    // Set up toggle button when DOM is ready
    document.addEventListener('DOMContentLoaded', function() {
        const toggleBtn = document.getElementById('themeToggle');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', function(e) {
                e.preventDefault();
                toggleTheme();
            });
        }
    });
    
    // Expose toggle function globally for potential external use
    window.toggleTheme = toggleTheme;
})();
