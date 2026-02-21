// ===================================
// Authentication & Dynamic Navigation
// ===================================

(function() {
    'use strict';

    const AUTH_KEY = 'tpm_auth';
    const USERS_KEY = 'tpm_users';

    // --- Auth Helper Functions ---

    function getAuthState() {
        try {
            const data = localStorage.getItem(AUTH_KEY);
            return data ? JSON.parse(data) : null;
        } catch (e) {
            return null;
        }
    }

    function setAuthState(user) {
        localStorage.setItem(AUTH_KEY, JSON.stringify({
            loggedIn: true,
            user: user
        }));
    }

    function clearAuthState() {
        localStorage.removeItem(AUTH_KEY);
    }

    function getUsers() {
        try {
            const data = localStorage.getItem(USERS_KEY);
            return data ? JSON.parse(data) : [];
        } catch (e) {
            return [];
        }
    }

    function addUser(userData) {
        const users = getUsers();
        users.push(userData);
        localStorage.setItem(USERS_KEY, JSON.stringify(users));
    }

    function findUser(email, password) {
        const users = getUsers();
        return users.find(u => u.email.toLowerCase() === email.toLowerCase() && u.password === password);
    }

    function getCurrentUserRole() {
        const auth = getAuthState();
        return auth && auth.loggedIn ? auth.user.role : null;
    }

    function isLoggedIn() {
        const auth = getAuthState();
        return auth && auth.loggedIn;
    }

    // Expose globally for other scripts
    window.TPMAuth = {
        getAuthState: getAuthState,
        setAuthState: setAuthState,
        clearAuthState: clearAuthState,
        getUsers: getUsers,
        addUser: addUser,
        findUser: findUser,
        getCurrentUserRole: getCurrentUserRole,
        isLoggedIn: isLoggedIn
    };

    // --- Dynamic Navigation Builder ---

    function getCurrentPage() {
        const path = window.location.pathname;
        const page = path.substring(path.lastIndexOf('/') + 1) || 'index.html';
        return page;
    }

    function buildNav() {
        const navMenu = document.getElementById('navMenu');
        if (!navMenu) return;

        const currentPage = getCurrentPage();
        const auth = getAuthState();
        const loggedIn = auth && auth.loggedIn;
        const role = loggedIn ? auth.user.role : null;

        let navHTML = '';

        // HOME
        navHTML += buildNavItem('index.html', 'HOME', currentPage);

        // ABOUT (dropdown)
        navHTML += buildDropdownItem('about.html', 'ABOUT', currentPage, [
            { href: 'about.html#about-us', label: 'About Us' },
            { href: 'about.html#founder', label: 'The Founder' },
            { href: 'about.html#database', label: 'Church Database' }
        ]);

        // MEDIA (dropdown)
        navHTML += buildDropdownItem('media.html', 'MEDIA', currentPage, [
            { href: 'media.html#live-streaming', label: 'Live Streaming' },
            { href: 'media.html#devotionals', label: 'Devotionals' },
            { href: 'media.html#picture-quotes', label: 'Picture Quotes' },
            { href: 'media.html#podcast', label: 'Podcast' },
            { href: 'media.html#apostle-andrews', label: 'Time with Apostle Andrews' },
            { href: 'media.html#success-secrets', label: 'Success Secrets' }
        ]);

        // CONTACT & UPDATES (dropdown)
        navHTML += buildDropdownItem('contact-updates.html', 'CONTACT & UPDATES', currentPage, [
            { href: 'contact-updates.html#announcements', label: 'Announcements' },
            { href: 'contact-updates.html#contact', label: 'Contact Us' }
        ]);

        // JOIN US (dropdown)
        navHTML += buildDropdownItem('join-us.html', 'JOIN US', currentPage, [
            { href: 'join-us.html#worker-groups', label: 'Worker Groups' },
            { href: 'join-us.html#branch', label: 'Visit a Branch Near You' }
        ]);

        // MEMBER PORTAL (dropdown, always visible)
        var portalItems = [
            { href: 'member-directory.html', label: 'Member Directory' },
            { href: 'update-profile.html', label: 'Update Profile' },
            { href: 'statistics.html', label: 'Church Statistics' }
        ];
        navHTML += buildDropdownItem('#', 'MEMBER PORTAL', currentPage, portalItems,
            ['member-directory.html', 'update-profile.html', 'statistics.html']);

        // PARTNER WITH US (dropdown)
        navHTML += buildDropdownItem('partner-with-us.html', 'PARTNER WITH US', currentPage, [
            { href: 'partner-with-us.html#partner', label: 'Partner with Us Today' }
        ]);

        // User info and logout removed from nav

        navMenu.innerHTML = navHTML;

        // Attach logout handler
        var logoutBtn = document.getElementById('logoutBtn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', function(e) {
                e.preventDefault();
                clearAuthState();
                window.location.href = 'index.html';
            });
        }
    }

    function buildNavItem(href, label, currentPage, childPages) {
        var isActive = (currentPage === href);
        if (childPages) {
            isActive = isActive || childPages.indexOf(currentPage) !== -1;
        }
        return '<li class="nav-item">' +
            '<a href="' + href + '" class="nav-link' + (isActive ? ' active' : '') + '">' + label + '</a>' +
            '</li>';
    }

    function buildDropdownItem(href, label, currentPage, items, childPages) {
        var isActive = (currentPage === href);
        if (childPages) {
            isActive = isActive || childPages.indexOf(currentPage) !== -1;
        }
        // Also check if any dropdown item page matches current
        items.forEach(function(item) {
            var itemPage = item.href.split('#')[0];
            if (itemPage === currentPage) isActive = true;
        });

        var html = '<li class="nav-item dropdown">';
        html += '<a href="' + href + '" class="nav-link' + (isActive ? ' active' : '') + '">' + label + '</a>';
        html += '<ul class="dropdown-menu">';
        items.forEach(function(item) {
            html += '<li><a href="' + item.href + '">' + item.label + '</a></li>';
        });
        html += '</ul>';
        html += '</li>';
        return html;
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    // --- Auth Page Logic ---

    function initAuthPage() {
        var authForms = document.getElementById('authForms');
        if (!authForms) return;

        // If already logged in, redirect home
        if (isLoggedIn()) {
            window.location.href = 'index.html';
            return;
        }

        // Tab switching
        var tabs = authForms.querySelectorAll('.auth-tab');
        var loginForm = document.getElementById('loginForm');
        var signupForm = document.getElementById('signupForm');

        tabs.forEach(function(tab) {
            tab.addEventListener('click', function() {
                tabs.forEach(function(t) { t.classList.remove('active'); });
                tab.classList.add('active');

                var target = tab.getAttribute('data-tab');
                if (target === 'login') {
                    loginForm.classList.add('active');
                    signupForm.classList.remove('active');
                } else {
                    signupForm.classList.add('active');
                    loginForm.classList.remove('active');
                }
            });
        });

        // Login handler
        if (loginForm) {
            loginForm.addEventListener('submit', function(e) {
                e.preventDefault();
                clearMessages(loginForm);

                var email = loginForm.querySelector('[name="loginEmail"]').value.trim();
                var password = loginForm.querySelector('[name="loginPassword"]').value;

                if (!email || !password) {
                    showFormError(loginForm, 'Please fill in all fields.');
                    return;
                }

                var user = findUser(email, password);
                if (!user) {
                    showFormError(loginForm, 'Invalid email or password. Please try again.');
                    return;
                }

                setAuthState({
                    fullName: user.fullName,
                    email: user.email,
                    phone: user.phone,
                    role: user.role
                });

                showFormSuccess(loginForm, 'Login successful! Redirecting...');
                setTimeout(function() {
                    window.location.href = 'index.html';
                }, 1000);
            });
        }

        // Signup handler
        if (signupForm) {
            signupForm.addEventListener('submit', function(e) {
                e.preventDefault();
                clearMessages(signupForm);

                var fullName = signupForm.querySelector('[name="signupName"]').value.trim();
                var email = signupForm.querySelector('[name="signupEmail"]').value.trim();
                var phone = signupForm.querySelector('[name="signupPhone"]').value.trim();
                var password = signupForm.querySelector('[name="signupPassword"]').value;
                var confirmPassword = signupForm.querySelector('[name="signupConfirmPassword"]').value;
                var role = signupForm.querySelector('[name="signupRole"]').value;

                // Validation
                if (!fullName || !email || !phone || !password || !confirmPassword || !role) {
                    showFormError(signupForm, 'Please fill in all fields.');
                    return;
                }

                if (!isValidEmail(email)) {
                    showFormError(signupForm, 'Please enter a valid email address.');
                    return;
                }

                if (!isValidPhone(phone)) {
                    showFormError(signupForm, 'Please enter a valid phone number.');
                    return;
                }

                if (password.length < 6) {
                    showFormError(signupForm, 'Password must be at least 6 characters.');
                    return;
                }

                if (password !== confirmPassword) {
                    showFormError(signupForm, 'Passwords do not match.');
                    return;
                }

                // Check if email already exists
                var existingUsers = getUsers();
                var emailExists = existingUsers.some(function(u) {
                    return u.email.toLowerCase() === email.toLowerCase();
                });
                if (emailExists) {
                    showFormError(signupForm, 'An account with this email already exists.');
                    return;
                }

                // Register user
                var newUser = {
                    fullName: fullName,
                    email: email,
                    phone: phone,
                    password: password,
                    role: role
                };
                addUser(newUser);

                // Auto login
                setAuthState({
                    fullName: newUser.fullName,
                    email: newUser.email,
                    phone: newUser.phone,
                    role: newUser.role
                });

                showFormSuccess(signupForm, 'Account created successfully! Redirecting...');
                setTimeout(function() {
                    window.location.href = 'index.html';
                }, 1000);
            });
        }
    }

    // --- Form Utility Functions ---

    function isValidEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    function isValidPhone(phone) {
        return /^[\+]?[\d\s\-\(\)]{7,15}$/.test(phone);
    }

    function showFormError(form, message) {
        var msgDiv = form.querySelector('.form-message');
        if (!msgDiv) {
            msgDiv = document.createElement('div');
            msgDiv.className = 'form-message';
            form.insertBefore(msgDiv, form.firstChild);
        }
        msgDiv.className = 'form-message form-message-error';
        msgDiv.textContent = message;
        msgDiv.style.display = 'block';
    }

    function showFormSuccess(form, message) {
        var msgDiv = form.querySelector('.form-message');
        if (!msgDiv) {
            msgDiv = document.createElement('div');
            msgDiv.className = 'form-message';
            form.insertBefore(msgDiv, form.firstChild);
        }
        msgDiv.className = 'form-message form-message-success';
        msgDiv.textContent = message;
        msgDiv.style.display = 'block';
    }

    function clearMessages(form) {
        var msgs = form.querySelectorAll('.form-message');
        msgs.forEach(function(msg) { msg.style.display = 'none'; });
    }

    // Expose form utilities globally
    window.TPMFormUtils = {
        isValidEmail: isValidEmail,
        isValidPhone: isValidPhone,
        showFormError: showFormError,
        showFormSuccess: showFormSuccess,
        clearMessages: clearMessages
    };

    // --- Inline Auth Forms (on portal/stats pages) ---

    function initInlineAuth() {
        var inlineLogin = document.getElementById('inlineLoginForm');
        var inlineSignup = document.getElementById('inlineSignupForm');
        if (!inlineLogin && !inlineSignup) return;

        // Tab switching within accessDenied section
        var accessDenied = document.getElementById('accessDenied');
        if (accessDenied) {
            var tabs = accessDenied.querySelectorAll('.auth-tab');
            tabs.forEach(function(tab) {
                tab.addEventListener('click', function() {
                    tabs.forEach(function(t) { t.classList.remove('active'); });
                    tab.classList.add('active');
                    var target = tab.getAttribute('data-tab');
                    if (target === 'login') {
                        inlineLogin.classList.add('active');
                        if (inlineSignup) inlineSignup.classList.remove('active');
                    } else {
                        if (inlineSignup) inlineSignup.classList.add('active');
                        inlineLogin.classList.remove('active');
                    }
                });
            });
        }

        // Inline login handler
        if (inlineLogin) {
            inlineLogin.addEventListener('submit', function(e) {
                e.preventDefault();
                clearMessages(inlineLogin);

                var email = (document.getElementById('inlineLoginEmail') || {}).value || '';
                var password = (document.getElementById('inlineLoginPassword') || {}).value || '';
                email = email.trim();

                if (!email || !password) {
                    showFormError(inlineLogin, 'Please fill in all fields.');
                    return;
                }

                var user = findUser(email, password);
                if (!user) {
                    showFormError(inlineLogin, 'Invalid email or password. Please try again.');
                    return;
                }

                setAuthState({
                    fullName: user.fullName,
                    email: user.email,
                    phone: user.phone,
                    role: user.role
                });

                showFormSuccess(inlineLogin, 'Login successful! Loading page...');
                setTimeout(function() {
                    window.location.reload();
                }, 800);
            });
        }

        // Inline signup handler
        if (inlineSignup) {
            inlineSignup.addEventListener('submit', function(e) {
                e.preventDefault();
                clearMessages(inlineSignup);

                var fullName = inlineSignup.querySelector('[name="signupName"]').value.trim();
                var email = inlineSignup.querySelector('[name="signupEmail"]').value.trim();
                var phone = inlineSignup.querySelector('[name="signupPhone"]').value.trim();
                var password = inlineSignup.querySelector('[name="signupPassword"]').value;
                var confirmPassword = inlineSignup.querySelector('[name="signupConfirmPassword"]').value;
                var role = inlineSignup.querySelector('[name="signupRole"]').value;

                if (!fullName || !email || !phone || !password || !confirmPassword || !role) {
                    showFormError(inlineSignup, 'Please fill in all fields.');
                    return;
                }
                if (!isValidEmail(email)) {
                    showFormError(inlineSignup, 'Please enter a valid email address.');
                    return;
                }
                if (!isValidPhone(phone)) {
                    showFormError(inlineSignup, 'Please enter a valid phone number.');
                    return;
                }
                if (password.length < 6) {
                    showFormError(inlineSignup, 'Password must be at least 6 characters.');
                    return;
                }
                if (password !== confirmPassword) {
                    showFormError(inlineSignup, 'Passwords do not match.');
                    return;
                }

                var existingUsers = getUsers();
                var emailExists = existingUsers.some(function(u) {
                    return u.email.toLowerCase() === email.toLowerCase();
                });
                if (emailExists) {
                    showFormError(inlineSignup, 'An account with this email already exists.');
                    return;
                }

                var newUser = { fullName: fullName, email: email, phone: phone, password: password, role: role };
                addUser(newUser);
                setAuthState({ fullName: newUser.fullName, email: newUser.email, phone: newUser.phone, role: newUser.role });

                showFormSuccess(inlineSignup, 'Account created! Loading page...');
                setTimeout(function() {
                    window.location.reload();
                }, 800);
            });
        }
    }

    // --- Seed Default Users ---
    function seedDefaultUsers() {
        var users = getUsers();
        var defaults = [
            { fullName: 'Admin Leader', email: 'admin@tpm.org', phone: '+233241000000', password: 'admin123', role: 'leader' },
            { fullName: 'John Member', email: 'member@tpm.org', phone: '+233241000001', password: 'member123', role: 'member' }
        ];
        defaults.forEach(function(def) {
            var exists = users.some(function(u) { return u.email.toLowerCase() === def.email.toLowerCase(); });
            if (!exists) {
                addUser(def);
            }
        });
    }

    // --- Initialize on DOM Ready ---

    document.addEventListener('DOMContentLoaded', function() {
        // Clear stale auto-login from previous version
        if (!localStorage.getItem('tpm_v2')) {
            clearAuthState();
            localStorage.setItem('tpm_v2', '1');
        }

        seedDefaultUsers();
        buildNav();
        initAuthPage();
        initInlineAuth();
    });

})();
