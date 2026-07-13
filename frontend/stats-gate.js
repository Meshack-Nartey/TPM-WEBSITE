// ===================================
// Statistics Dashboard — Access Gate
// ===================================
// Distributes access codes manually to authorised leaders.
// Edit VALID_CODES to add or remove codes at any time.
// Each code here is reusable (the same code can be entered by multiple
// authorised people). To make a code single-use, remove it from the list
// after it has been used.
// ===================================

(function () {
    'use strict';

    var LOCKOUT_STORAGE_KEY = 'tpm_stats_lockout';
    var MAX_ATTEMPTS        = 5;
    var LOCKOUT_DURATION_MS = 15 * 60 * 1000; // 15 minutes

    // -----------------------------------------------
    // VALID ACCESS CODES
    // Distribute these manually to authorised leaders.
    // All codes are case-insensitive.
    // -----------------------------------------------
    var VALID_CODES = [
        'OYOF'
    ];

    // --- Helpers ---

    function getLockout() {
        try {
            return JSON.parse(localStorage.getItem(LOCKOUT_STORAGE_KEY)) || { attempts: 0, until: 0 };
        } catch (e) {
            return { attempts: 0, until: 0 };
        }
    }

    function saveLockout(data) {
        try { localStorage.setItem(LOCKOUT_STORAGE_KEY, JSON.stringify(data)); }
        catch (e) {}
    }

    function isLockedOut() {
        var d = getLockout();
        if (d.until && Date.now() < d.until) return true;
        if (d.until && Date.now() >= d.until) saveLockout({ attempts: 0, until: 0 });
        return false;
    }

    function minutesRemaining() {
        var d = getLockout();
        return Math.max(1, Math.ceil((d.until - Date.now()) / 60000));
    }

    function recordFailure() {
        var d = getLockout();
        d.attempts = (d.attempts || 0) + 1;
        if (d.attempts >= MAX_ATTEMPTS) d.until = Date.now() + LOCKOUT_DURATION_MS;
        saveLockout(d);
        return d.attempts;
    }

    function resetLockout() {
        saveLockout({ attempts: 0, until: 0 });
    }

    function validate(code) {
        return VALID_CODES.indexOf(code.trim().toUpperCase()) !== -1;
    }

    // --- UI Helpers ---

    function showError(msg) {
        var el = document.getElementById('gateError');
        if (!el) return;
        el.textContent = msg;
        el.classList.add('visible');
    }

    function clearError() {
        var el = document.getElementById('gateError');
        if (!el) return;
        el.textContent = '';
        el.classList.remove('visible');
    }

    // --- Gate HTML ---

    function injectGate() {
        var overlay = document.createElement('div');
        overlay.id = 'statsGateOverlay';
        overlay.className = 'stats-gate-overlay';
        overlay.innerHTML =
            '<div class="stats-gate-card">' +
                '<div class="stats-gate-logo">' +
                    '<img src="assets/images/TPM LOGO WHITE.png" alt="TPM Logo">' +
                '</div>' +
                '<p class="stats-gate-ministry">Transformation Project Ministries</p>' +
                '<h1 class="stats-gate-title">Statistics Dashboard</h1>' +
                '<div class="stats-gate-rule"></div>' +
                '<p class="stats-gate-desc">' +
                    'This area is restricted to authorised church leaders.<br>' +
                    'Enter your access code to continue.' +
                '</p>' +
                '<form id="gateForm" class="stats-gate-form" autocomplete="off">' +
                    '<div class="stats-gate-input-wrap">' +
                        '<input type="password" id="gateCodeInput" class="stats-gate-input"' +
                            ' placeholder="Enter access code" maxlength="40"' +
                            ' autocomplete="new-password" spellcheck="false">' +
                        '<button type="button" id="gateEyeBtn" class="stats-gate-eye" title="Show / hide code">' +
                            '<svg width="18" height="18" viewBox="0 0 24 24" fill="none"' +
                                ' stroke="currentColor" stroke-width="2"' +
                                ' stroke-linecap="round" stroke-linejoin="round">' +
                                '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>' +
                                '<circle cx="12" cy="12" r="3"/>' +
                            '</svg>' +
                        '</button>' +
                    '</div>' +
                    '<p class="stats-gate-error" id="gateError"></p>' +
                    '<button type="submit" class="stats-gate-btn" id="gateSubmitBtn">Verify Access</button>' +
                '</form>' +
                '<p class="stats-gate-hint">' +
                    'Contact your church administrator if you need an access code.' +
                '</p>' +
            '</div>';

        document.body.appendChild(overlay);
        document.body.style.overflow = 'hidden';

        // Wire up events
        document.getElementById('gateForm').addEventListener('submit', function (e) {
            e.preventDefault();
            handleSubmit();
        });

        document.getElementById('gateEyeBtn').addEventListener('click', function () {
            var inp = document.getElementById('gateCodeInput');
            inp.type = inp.type === 'password' ? 'text' : 'password';
        });

        // Auto-focus
        setTimeout(function () {
            var inp = document.getElementById('gateCodeInput');
            if (inp) inp.focus();
        }, 80);

        // Restore lockout state if already locked
        if (isLockedOut()) applyLockoutUI();
    }

    function applyLockoutUI() {
        var inp  = document.getElementById('gateCodeInput');
        var btn  = document.getElementById('gateSubmitBtn');
        var mins = minutesRemaining();

        if (inp) inp.disabled = true;
        if (btn) { btn.disabled = true; btn.textContent = 'Locked (' + mins + 'm)'; }

        showError(
            'Too many failed attempts. Please try again in ' +
            mins + ' minute' + (mins !== 1 ? 's' : '') + '.'
        );

        // Refresh countdown every 30 s
        var timer = setInterval(function () {
            if (!isLockedOut()) {
                clearInterval(timer);
                if (inp) inp.disabled = false;
                if (btn) { btn.disabled = false; btn.textContent = 'Verify Access'; }
                clearError();
                if (inp) inp.focus();
            } else {
                var m = minutesRemaining();
                if (btn) btn.textContent = 'Locked (' + m + 'm)';
                showError(
                    'Too many failed attempts. Please try again in ' +
                    m + ' minute' + (m !== 1 ? 's' : '') + '.'
                );
            }
        }, 30000);
    }

    function handleSubmit() {
        if (isLockedOut()) { applyLockoutUI(); return; }

        var inp  = document.getElementById('gateCodeInput');
        var code = inp ? inp.value : '';

        if (!code.trim()) {
            showError('Please enter your access code.');
            return;
        }

        if (validate(code)) {
            resetLockout();
            showGrantedState();
        } else {
            var attempts = recordFailure();
            if (inp) inp.value = '';

            if (isLockedOut()) {
                applyLockoutUI();
            } else {
                var left = MAX_ATTEMPTS - attempts;
                showError(
                    'Incorrect access code. ' +
                    left + ' attempt' + (left !== 1 ? 's' : '') + ' remaining.'
                );
                if (inp) inp.focus();
            }
        }
    }

    function showGrantedState() {
        var card = document.querySelector('.stats-gate-card');
        if (card) {
            card.innerHTML =
                '<div class="stats-gate-check">&#10003;</div>' +
                '<h2 class="stats-gate-title" style="margin-top:20px;">Access Granted</h2>' +
                '<p class="stats-gate-desc" style="margin-top:10px;">Welcome. Loading dashboard\u2026</p>';
        }

        var overlay = document.getElementById('statsGateOverlay');
        if (overlay) overlay.classList.add('stats-gate-granted');

        setTimeout(function () {
            if (overlay) {
                overlay.style.transition = 'opacity 0.5s ease';
                overlay.style.opacity    = '0';
            }
            setTimeout(function () {
                if (overlay) overlay.remove();
                document.body.style.overflow = '';
            }, 500);
        }, 950);
    }

    // --- Init ---

    function init() {
        injectGate();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
