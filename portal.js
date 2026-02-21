// ===================================
// Member Portal Functionality
// ===================================

(function() {
    'use strict';

    // --- Access Guard ---
    function requireAuth(minRole) {
        if (!window.TPMAuth || !window.TPMAuth.isLoggedIn()) {
            showAccessMessage('Please log in to access this page.', true);
            return false;
        }
        if (minRole === 'leader' && window.TPMAuth.getCurrentUserRole() !== 'leader') {
            showAccessMessage('Access restricted to church leaders.', false);
            return false;
        }
        return true;
    }

    function showAccessMessage(message, showLogin) {
        var mainContent = document.getElementById('mainContent');
        if (mainContent) mainContent.style.display = 'none';

        var denied = document.getElementById('accessDenied');
        if (denied) {
            denied.style.display = 'block';
            var msgEl = denied.querySelector('.access-denied-text');
            if (msgEl) msgEl.textContent = message;
            var loginLink = denied.querySelector('.access-denied-login');
            if (loginLink) loginLink.style.display = showLogin ? 'inline-block' : 'none';
        }
    }

    // --- Member Directory (Registration Form) ---
    function initMemberDirectory() {
        var form = document.getElementById('memberDirectoryForm');
        if (!form) return;
        if (!requireAuth('member')) return;

        document.getElementById('mainContent').style.display = 'block';

        // Show profile info for registered user
        renderMyProfile();

        // Populate dropdowns from mock data
        populateSelect('branchSelect', TPM_MOCK_DATA.branches);
        populateSelect('departmentSelect', TPM_MOCK_DATA.departments);
        populateSelect('membershipStatusSelect', TPM_MOCK_DATA.membershipStatuses);

        // Photo preview
        var photoInput = document.getElementById('profilePhotoInput');
        var photoPreview = document.getElementById('photoPreview');
        if (photoInput && photoPreview) {
            photoInput.addEventListener('change', function() {
                var file = this.files[0];
                if (file) {
                    if (file.size > 5 * 1024 * 1024) {
                        window.TPMFormUtils.showFormError(form, 'Photo must be less than 5MB.');
                        this.value = '';
                        return;
                    }
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        photoPreview.src = e.target.result;
                        photoPreview.style.display = 'block';
                    };
                    reader.readAsDataURL(file);
                } else {
                    photoPreview.style.display = 'none';
                }
            });
        }

        // Form submission
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            window.TPMFormUtils.clearMessages(form);

            // Validate required fields
            var firstName = form.querySelector('[name="firstName"]').value.trim();
            var lastName = form.querySelector('[name="lastName"]').value.trim();
            var dob = form.querySelector('[name="dob"]').value;
            var gender = form.querySelector('[name="gender"]').value;
            var phone = form.querySelector('[name="phone"]').value.trim();
            var email = form.querySelector('[name="email"]').value.trim();
            var address = form.querySelector('[name="address"]').value.trim();
            var branch = form.querySelector('[name="branch"]').value;
            var department = form.querySelector('[name="department"]').value;
            var dateJoined = form.querySelector('[name="dateJoined"]').value;
            var membershipStatus = form.querySelector('[name="membershipStatus"]').value;
            var emergencyName = form.querySelector('[name="emergencyContactName"]').value.trim();
            var emergencyPhone = form.querySelector('[name="emergencyContactPhone"]').value.trim();

            if (!firstName || !lastName || !dob || !gender || !phone || !email ||
                !address || !branch || !department || !dateJoined || !membershipStatus ||
                !emergencyName || !emergencyPhone) {
                window.TPMFormUtils.showFormError(form, 'Please fill in all required fields.');
                return;
            }

            if (!window.TPMFormUtils.isValidEmail(email)) {
                window.TPMFormUtils.showFormError(form, 'Please enter a valid email address.');
                return;
            }

            if (!window.TPMFormUtils.isValidPhone(phone)) {
                window.TPMFormUtils.showFormError(form, 'Please enter a valid phone number.');
                return;
            }

            if (!window.TPMFormUtils.isValidPhone(emergencyPhone)) {
                window.TPMFormUtils.showFormError(form, 'Please enter a valid emergency contact phone number.');
                return;
            }

            // Save registration to localStorage
            var regData = {
                firstName: firstName, lastName: lastName, dob: dob, gender: gender,
                phone: phone, email: email, address: address, branch: branch,
                department: department, dateJoined: dateJoined, membershipStatus: membershipStatus,
                emergencyContactName: emergencyName, emergencyContactPhone: emergencyPhone
            };
            var auth = window.TPMAuth.getAuthState();
            var regKey = 'tpm_registration_' + (auth && auth.user ? auth.user.email : 'guest');
            localStorage.setItem(regKey, JSON.stringify(regData));

            // Success
            window.TPMFormUtils.showFormSuccess(form, 'Registration submitted successfully! Welcome to TPM.');
            form.reset();
            if (photoPreview) photoPreview.style.display = 'none';

            // Refresh profile display
            renderMyProfile();

            // Scroll to top to show profile and message
            var profileCard = document.getElementById('myProfileCard');
            if (profileCard) profileCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });
    }

    // --- My Profile Display ---
    function renderMyProfile() {
        var card = document.getElementById('myProfileCard');
        var grid = document.getElementById('profileInfoGrid');
        if (!card || !grid) return;

        // Get logged-in user's registration from localStorage
        var auth = window.TPMAuth.getAuthState();
        if (!auth || !auth.user) return;

        var regKey = 'tpm_registration_' + auth.user.email;
        var stored = localStorage.getItem(regKey);
        if (!stored) {
            // No registration yet — hide profile card
            card.style.display = 'none';
            return;
        }

        var member = JSON.parse(stored);
        card.style.display = 'block';

        var fields = [
            { label: 'First Name', value: member.firstName },
            { label: 'Last Name', value: member.lastName },
            { label: 'Date of Birth', value: formatDate(member.dob) },
            { label: 'Gender', value: member.gender },
            { label: 'Phone Number', value: member.phone },
            { label: 'Email Address', value: member.email },
            { label: 'Home Address', value: member.address, full: true },
            { label: 'Church Branch', value: member.branch },
            { label: 'Department', value: member.department },
            { label: 'Date Joined', value: formatDate(member.dateJoined) },
            { label: 'Membership Status', value: member.membershipStatus },
            { label: 'Emergency Contact', value: member.emergencyContactName },
            { label: 'Emergency Phone', value: member.emergencyContactPhone }
        ];

        grid.innerHTML = fields.map(function(f) {
            var cls = f.full ? ' full-width' : '';
            return '<div class="profile-info-item' + cls + '">' +
                '<span class="profile-info-label">' + escapeHtml(f.label) + '</span>' +
                '<span class="profile-info-value">' + escapeHtml(f.value) + '</span>' +
                '</div>';
        }).join('');
    }

    function formatDate(dateStr) {
        if (!dateStr) return '-';
        var d = new Date(dateStr);
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
    }

    // --- Update Profile ---
    function initUpdateProfile() {
        var form = document.getElementById('updateProfileForm');
        if (!form) return;
        if (!requireAuth('member')) return;

        document.getElementById('mainContent').style.display = 'block';

        // Populate dropdowns
        populateSelect('editBranchSelect', TPM_MOCK_DATA.branches);
        populateSelect('editDepartmentSelect', TPM_MOCK_DATA.departments);
        populateSelect('editMembershipStatusSelect', TPM_MOCK_DATA.membershipStatuses);

        // Pre-populate with mock member data (first member)
        var member = TPM_MOCK_DATA.members[0];
        form.querySelector('[name="firstName"]').value = member.firstName;
        form.querySelector('[name="lastName"]').value = member.lastName;
        form.querySelector('[name="dob"]').value = member.dob;
        form.querySelector('[name="gender"]').value = member.gender;
        form.querySelector('[name="phone"]').value = member.phone;
        form.querySelector('[name="email"]').value = member.email;
        form.querySelector('[name="address"]').value = member.address;
        form.querySelector('[name="branch"]').value = member.branch;
        form.querySelector('[name="department"]').value = member.department;
        form.querySelector('[name="dateJoined"]').value = member.dateJoined;
        form.querySelector('[name="membershipStatus"]').value = member.membershipStatus;
        form.querySelector('[name="emergencyContactName"]').value = member.emergencyContactName;
        form.querySelector('[name="emergencyContactPhone"]').value = member.emergencyContactPhone;

        // Form submission
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            window.TPMFormUtils.clearMessages(form);

            var email = form.querySelector('[name="email"]').value.trim();
            var phone = form.querySelector('[name="phone"]').value.trim();

            if (email && !window.TPMFormUtils.isValidEmail(email)) {
                window.TPMFormUtils.showFormError(form, 'Please enter a valid email address.');
                return;
            }

            if (phone && !window.TPMFormUtils.isValidPhone(phone)) {
                window.TPMFormUtils.showFormError(form, 'Please enter a valid phone number.');
                return;
            }

            window.TPMFormUtils.showFormSuccess(form, 'Your update request has been submitted for leader approval.');
            form.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });

        // Render request status table
        renderRequestStatus();
    }

    function renderRequestStatus() {
        var tableBody = document.getElementById('requestStatusBody');
        if (!tableBody) return;

        var requests = TPM_MOCK_DATA.profileUpdateRequests.filter(function(r) {
            return r.memberId === 1; // Current mock user
        });

        if (requests.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="5" style="text-align:center; color: var(--text-gray);">No update requests found.</td></tr>';
            return;
        }

        tableBody.innerHTML = requests.map(function(req) {
            var statusClass = req.status.toLowerCase();
            return '<tr>' +
                '<td>' + escapeHtml(req.field) + '</td>' +
                '<td>' + escapeHtml(req.oldValue) + '</td>' +
                '<td>' + escapeHtml(req.newValue) + '</td>' +
                '<td><span class="status-badge ' + statusClass + '">' + req.status + '</span></td>' +
                '<td>' + req.date + '</td>' +
                '</tr>';
        }).join('');
    }

    // --- Utility Functions ---

    function populateSelect(selectId, options) {
        var select = document.getElementById(selectId);
        if (!select) return;
        // Keep the first option (placeholder)
        var firstOption = select.querySelector('option');
        select.innerHTML = '';
        if (firstOption) select.appendChild(firstOption);

        options.forEach(function(opt) {
            var option = document.createElement('option');
            option.value = opt;
            option.textContent = opt;
            select.appendChild(option);
        });
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    // --- Initialize ---
    document.addEventListener('DOMContentLoaded', function() {
        initMemberDirectory();
        initUpdateProfile();
    });

})();
