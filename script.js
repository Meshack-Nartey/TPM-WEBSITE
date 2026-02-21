// ===================================
// Hero Slider Functionality
// ===================================

document.addEventListener('DOMContentLoaded', function() {

    // Initialize Hero Slider
    initHeroSlider();

    // Initialize About Page Flowing Backgrounds
    initFlowingBackgrounds();
    initAboutScrollReveal();

    // Initialize Mobile Navigation
    initMobileNav();

    // Initialize Smooth Scrolling
    initSmoothScroll();

    // Initialize Scroll Animations
    initScrollAnimations();
});

// ===================================
// Hero Slider
// ===================================
function initHeroSlider() {
    const slides = document.querySelectorAll('.slide');
    const dotsContainer = document.getElementById('sliderDots');
    const prevBtn = document.getElementById('prevSlide');
    const nextBtn = document.getElementById('nextSlide');

    if (!slides.length) return; // Exit if no slider on page

    let currentSlide = 0;
    const totalSlides = slides.length;
    let autoSlideInterval;
    const HERO_SLIDE_INTERVAL = 2500;
    
    // Create dots
    slides.forEach((_, index) => {
        const dot = document.createElement('div');
        dot.classList.add('dot');
        if (index === 0) dot.classList.add('active');
        dot.addEventListener('click', () => goToSlide(index));
        dotsContainer.appendChild(dot);
    });
    
    const dots = document.querySelectorAll('.dot');
    
    // Show specific slide
    function showSlide(n) {
        // Wrap around
        if (n >= totalSlides) {
            currentSlide = 0;
        } else if (n < 0) {
            currentSlide = totalSlides - 1;
        } else {
            currentSlide = n;
        }
        
        // Update slides
        slides.forEach((slide, index) => {
            slide.classList.remove('active');
            if (index === currentSlide) {
                slide.classList.add('active');
            }
        });
        
        // Update dots
        dots.forEach((dot, index) => {
            dot.classList.remove('active');
            if (index === currentSlide) {
                dot.classList.add('active');
            }
        });
    }
    
    // Navigate to specific slide
    function goToSlide(n) {
        resetAutoSlide();
        showSlide(n);
    }
    
    // Next slide
    function nextSlide() {
        resetAutoSlide();
        showSlide(currentSlide + 1);
    }
    
    // Previous slide
    function prevSlide() {
        resetAutoSlide();
        showSlide(currentSlide - 1);
    }
    
    // Auto slide every 2.5 seconds
    function startAutoSlide() {
        autoSlideInterval = setInterval(() => {
            showSlide(currentSlide + 1);
        }, HERO_SLIDE_INTERVAL);
    }

    // Reset auto slide timer
    function resetAutoSlide() {
        clearInterval(autoSlideInterval);
        startAutoSlide();
    }
    
    // Event listeners
    if (nextBtn) nextBtn.addEventListener('click', nextSlide);
    if (prevBtn) prevBtn.addEventListener('click', prevSlide);
    
    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft') {
            prevSlide();
        } else if (e.key === 'ArrowRight') {
            nextSlide();
        }
    });
    
    // Touch/Swipe support for mobile
    let touchStartX = 0;
    let touchEndX = 0;
    
    const heroSection = document.querySelector('.hero-section');
    
    if (heroSection) {
        heroSection.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
        });
        
        heroSection.addEventListener('touchend', (e) => {
            touchEndX = e.changedTouches[0].screenX;
            handleSwipe();
        });
        
        function handleSwipe() {
            const swipeThreshold = 50;
            if (touchEndX < touchStartX - swipeThreshold) {
                nextSlide(); // Swipe left
            }
            if (touchEndX > touchStartX + swipeThreshold) {
                prevSlide(); // Swipe right
            }
        }
    }
    
    // Start auto slide
    startAutoSlide();
    
    // Pause auto slide on hover
    if (heroSection) {
        heroSection.addEventListener('mouseenter', () => {
            clearInterval(autoSlideInterval);
        });
        
        heroSection.addEventListener('mouseleave', () => {
            startAutoSlide();
        });
    }
}

// ===================================
// About Page - Flowing Background Images
// ===================================
function initFlowingBackgrounds() {
    const sections = document.querySelectorAll('.about-section');

    if (!sections.length) return;

    sections.forEach(section => {
        const bgContainer = section.querySelector('.section-bg');
        const images = JSON.parse(section.dataset.images);

        // Create image elements
        images.forEach((src, index) => {
            const div = document.createElement('div');
            div.classList.add('bg-image');
            div.style.backgroundImage = `url('${src}')`;
            div.style.animationDelay = `${index * -7}s`;
            if (index === 0) div.classList.add('active');
            bgContainer.appendChild(div);
        });

        // Crossfade between images
        if (images.length > 1) {
            let current = 0;
            const bgImages = bgContainer.querySelectorAll('.bg-image');

            setInterval(() => {
                bgImages[current].classList.remove('active');
                current = (current + 1) % bgImages.length;
                bgImages[current].classList.add('active');
            }, 5000);
        }
    });
}

// ===================================
// About Page - Scroll Reveal
// ===================================
function initAboutScrollReveal() {
    const sections = document.querySelectorAll('.about-section');

    if (!sections.length) return;

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, {
        threshold: 0.2
    });

    sections.forEach(section => observer.observe(section));
}

// ===================================
// Mobile Navigation
// ===================================
function initMobileNav() {
    const hamburger = document.getElementById('hamburger');
    const navMenu = document.getElementById('navMenu');
    
    if (hamburger && navMenu) {
        hamburger.addEventListener('click', () => {
            hamburger.classList.toggle('active');
            navMenu.classList.toggle('active');
        });
        
        // Close menu when clicking a link
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', () => {
                hamburger.classList.remove('active');
                navMenu.classList.remove('active');
            });
        });
        
        // Close menu when clicking outside
        document.addEventListener('click', (e) => {
            if (!hamburger.contains(e.target) && !navMenu.contains(e.target)) {
                hamburger.classList.remove('active');
                navMenu.classList.remove('active');
            }
        });
    }
}

// ===================================
// Smooth Scrolling
// ===================================
function initSmoothScroll() {
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            
            // Skip if href is just "#"
            if (href === '#') {
                e.preventDefault();
                return;
            }
            
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                const headerOffset = 100;
                const elementPosition = target.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// ===================================
// Scroll Animations
// ===================================
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-on-scroll');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    // Observe elements
    const animateElements = document.querySelectorAll('.glass, .section-header, .content-text');
    animateElements.forEach(el => observer.observe(el));
}

// ===================================
// Header Scroll Effect
// ===================================
window.addEventListener('scroll', () => {
    const header = document.querySelector('.header');
    if (window.scrollY > 50) {
        header.style.background = 'rgba(255, 255, 255, 0.95)';
        header.style.backdropFilter = 'blur(16px)';
        header.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.1)';
    } else {
        header.style.background = 'rgba(255, 255, 255, 0.15)';
        header.style.backdropFilter = 'blur(12px)';
        header.style.boxShadow = 'none';
    }
});

// ===================================
// Form Validation (Contact & Giving Forms)
// ===================================
const forms = document.querySelectorAll('form');
forms.forEach(form => {
    // Skip forms handled by auth.js, portal.js, and statistics.js
    if (form.id === 'inlineLoginForm' || form.id === 'inlineSignupForm' ||
        form.id === 'loginForm' || form.id === 'signupForm' ||
        form.id === 'memberDirectoryForm' || form.id === 'updateProfileForm' ||
        form.id === 'dataEntryForm') {
        return;
    }

    form.addEventListener('submit', function(e) {
        e.preventDefault();

        // Basic validation
        const inputs = form.querySelectorAll('input[required], textarea[required], select[required]');
        let isValid = true;

        inputs.forEach(input => {
            if (!input.value.trim()) {
                isValid = false;
                input.style.borderColor = '#ef4444';
            } else {
                input.style.borderColor = '#dbeafe';
            }
        });

        if (isValid) {
            // Show success message
            showNotification('Thank you! Your submission has been received.', 'success');
            form.reset();
        } else {
            showNotification('Please fill in all required fields.', 'error');
        }
    });
});

// ===================================
// Notification System
// ===================================
function showNotification(message, type = 'success') {
    // Remove existing notification
    const existing = document.querySelector('.notification');
    if (existing) existing.remove();
    
    // Create notification
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    // Style notification
    Object.assign(notification.style, {
        position: 'fixed',
        top: '100px',
        right: '20px',
        padding: '20px 30px',
        borderRadius: '12px',
        background: type === 'success' ? '#10b981' : '#ef4444',
        color: 'white',
        fontWeight: '600',
        boxShadow: '0 10px 30px rgba(0, 0, 0, 0.2)',
        zIndex: '9999',
        animation: 'slideInRight 0.3s ease',
        maxWidth: '400px'
    });
    
    document.body.appendChild(notification);
    
    // Remove after 4 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 4000);
}

// Add notification animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// ===================================
// Back to Top Button
// ===================================
function createBackToTopButton() {
    const button = document.createElement('button');
    button.innerHTML = '↑';
    button.className = 'back-to-top';
    
    Object.assign(button.style, {
        position: 'fixed',
        bottom: '30px',
        right: '30px',
        width: '50px',
        height: '50px',
        borderRadius: '50%',
        background: 'linear-gradient(135deg, #D4AF37 0%, #B8941F 100%)',
        color: 'white',
        border: 'none',
        fontSize: '24px',
        cursor: 'pointer',
        opacity: '0',
        visibility: 'hidden',
        transition: 'all 0.3s ease',
        zIndex: '999',
        boxShadow: '0 4px 15px rgba(212, 175, 55, 0.3)'
    });
    
    button.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
    
    // Show/hide based on scroll
    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
            button.style.opacity = '1';
            button.style.visibility = 'visible';
        } else {
            button.style.opacity = '0';
            button.style.visibility = 'hidden';
        }
    });
    
    document.body.appendChild(button);
}

createBackToTopButton();

// ===================================
// Lazy Loading Images
// ===================================
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                    observer.unobserve(img);
                }
            }
        });
    });
    
    const lazyImages = document.querySelectorAll('img[data-src]');
    lazyImages.forEach(img => imageObserver.observe(img));
}

// ===================================
// Counter Animation (for stats if needed)
// ===================================
function animateCounter(element, start, end, duration) {
    let current = start;
    const range = end - start;
    const increment = range / (duration / 16);
    
    const timer = setInterval(() => {
        current += increment;
        if (current >= end) {
            current = end;
            clearInterval(timer);
        }
        element.textContent = Math.floor(current);
    }, 16);
}

// ===================================
// Page Load Performance
// ===================================
window.addEventListener('load', () => {
    // Remove preloader if exists
    const preloader = document.querySelector('.preloader');
    if (preloader) {
        preloader.style.opacity = '0';
        setTimeout(() => preloader.remove(), 300);
    }
    
    // Log performance metrics (optional, for development)
    if (window.performance) {
        const perfData = window.performance.timing;
        const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
        console.log(`Page loaded in ${pageLoadTime}ms`);
    }
});

// ===================================
// Accessibility: Skip to Content
// ===================================
const skipLink = document.createElement('a');
skipLink.href = '#main-content';
skipLink.textContent = 'Skip to main content';
skipLink.className = 'skip-link';

Object.assign(skipLink.style, {
    position: 'absolute',
    top: '-40px',
    left: '0',
    background: '#1e3a8a',
    color: 'white',
    padding: '8px',
    textDecoration: 'none',
    zIndex: '10000'
});

skipLink.addEventListener('focus', () => {
    skipLink.style.top = '0';
});

skipLink.addEventListener('blur', () => {
    skipLink.style.top = '-40px';
});

document.body.insertBefore(skipLink, document.body.firstChild);

// ===================================
// Console Welcome Message
// ===================================
console.log('%cWelcome to Transformation Project Ministries! 🙏', 
    'color: #1e3a8a; font-size: 20px; font-weight: bold;');
console.log('%cExperience the transforming power of God\'s love', 
    'color: #D4AF37; font-size: 14px;');
