// ===================================
// Authentication & Dynamic Navigation
// ===================================

(function() {
    'use strict';

    const AUTH_KEY = 'tpm_auth';
    const USERS_KEY = 'tpm_users';
    const LEADER_CODE = 'TPM-LEADER-2026'; // Change this code and share it only with verified leaders

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
            { href: 'about.html#founder', label: 'The Founder' }
        ]);

        // BOOKS (dropdown)
        navHTML += buildDropdownItem('books.html', 'BOOKS', currentPage, [
            { href: 'books.html#buy', label: 'Buy Books' },
            { href: 'books.html#free', label: 'Free Resources' },
            { href: 'books.html#devotional', label: 'Daily Devotional' }
        ]);

        // MEDIA (dropdown)
        navHTML += buildDropdownItem('media.html', 'MEDIA', currentPage, [
            { href: 'media.html#live-streaming', label: '<span class="nav-live-dot"></span>Live Streaming' },
            { href: 'media.html#devotionals', label: 'Devotionals' },
            { href: 'media.html#picture-quotes', label: 'Picture Quotes' },
            { href: 'media.html#podcast', label: 'Podcast' },
            { href: 'media.html#apostle-andrews', label: 'Time with Apostle Andrews' },
            { href: 'media.html#success-secrets', label: 'Success Secrets' },
            { href: 'media.html#social-media', label: 'Social Media' }
        ]);

        // GIVE (dropdown)
        navHTML += buildDropdownItem('give.html', 'GIVE', currentPage, [
            { href: 'give.html#local-accounts', label: 'Local Accounts' },
            { href: 'give.html#bank-transfer', label: 'Bank Transfer' }
        ]);

        // CONTACT
        navHTML += buildNavItem('contact-updates.html', 'CONTACT', currentPage);

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

        // Search icon trigger
        navHTML += '<li class="nav-item nav-search-trigger">' +
            '<button class="search-nav-btn" onclick="openTPMSearch()" aria-label="Search">' +
            '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>' +
            '</button></li>';

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

        // If already logged in, show a banner instead of redirecting
        var loggedInBanner = document.getElementById('loggedInBanner');
        if (isLoggedIn()) {
            var auth = getAuthState();
            if (loggedInBanner && auth && auth.user) {
                var nameEl = loggedInBanner.querySelector('.logged-in-name');
                if (nameEl) nameEl.textContent = auth.user.fullName;
                loggedInBanner.style.display = 'block';
            }
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

        // Show leader code field when "Leader" role is selected
        var roleSelect = document.getElementById('signupRole');
        var leaderCodeGroup = document.getElementById('leaderCodeGroup');
        if (roleSelect && leaderCodeGroup) {
            roleSelect.addEventListener('change', function() {
                leaderCodeGroup.style.display = this.value === 'leader' ? 'block' : 'none';
                var codeInput = document.getElementById('signupLeaderCode');
                if (codeInput) codeInput.required = this.value === 'leader';
            });
        }

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
                var leaderCodeInput = signupForm.querySelector('[name="signupLeaderCode"]');
                var leaderCode = leaderCodeInput ? leaderCodeInput.value.trim() : '';

                // Validation
                if (!fullName || !email || !phone || !password || !confirmPassword || !role) {
                    showFormError(signupForm, 'Please fill in all fields.');
                    return;
                }

                if (role === 'leader' && leaderCode !== LEADER_CODE) {
                    showFormError(signupForm, 'Invalid leader access code. Please contact TPM administration.');
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

        // Banner logout button
        var bannerLogoutBtn = document.getElementById('bannerLogoutBtn');
        if (bannerLogoutBtn) {
            bannerLogoutBtn.addEventListener('click', function() {
                clearAuthState();
                window.location.reload();
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
                var inlineLeaderCodeInput = inlineSignup.querySelector('[name="signupLeaderCode"]');
                var inlineLeaderCode = inlineLeaderCodeInput ? inlineLeaderCodeInput.value.trim() : '';

                if (!fullName || !email || !phone || !password || !confirmPassword || !role) {
                    showFormError(inlineSignup, 'Please fill in all fields.');
                    return;
                }

                if (role === 'leader' && inlineLeaderCode !== LEADER_CODE) {
                    showFormError(inlineSignup, 'Invalid leader access code. Please contact TPM administration.');
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

    // --- Initialize on DOM Ready ---

    document.addEventListener('DOMContentLoaded', function() {
        // Clear any stale sessions from previous versions
        if (!localStorage.getItem('tpm_v3')) {
            clearAuthState();
            localStorage.removeItem('tpm_v2');
            localStorage.setItem('tpm_v3', '1');
        }

        buildNav();
        initAuthPage();
        initInlineAuth();
    });

})();
