// ===================================
// Church Statistics Dashboard
// ===================================

(function() {
    'use strict';

    var attendanceChart = null;
    var branchChart = null;

    function initStatisticsDashboard() {
        var dashboardContent = document.getElementById('dashboardContent');
        if (!dashboardContent) return;

        // Access check
        if (!window.TPMAuth || !window.TPMAuth.isLoggedIn()) {
            document.getElementById('accessDenied').style.display = 'block';
            var msgEl = document.querySelector('#accessDenied .access-denied-text');
            if (msgEl) msgEl.textContent = 'Please log in to access this page.';
            var loginLink = document.querySelector('#accessDenied .access-denied-login');
            if (loginLink) loginLink.style.display = 'inline-block';
            return;
        }

        if (window.TPMAuth.getCurrentUserRole() !== 'leader') {
            document.getElementById('accessDenied').style.display = 'block';
            var msgEl2 = document.querySelector('#accessDenied .access-denied-text');
            if (msgEl2) msgEl2.textContent = 'Access restricted to church leaders.';
            var loginLink2 = document.querySelector('#accessDenied .access-denied-login');
            if (loginLink2) loginLink2.style.display = 'none';
            return;
        }

        dashboardContent.style.display = 'block';

        populateSummaryCards();
        populateFilters();
        initAttendanceChart();
        initBranchChart();
        initDataTables();
        initDataEntryForm();
        initRequestsTable();
    }

    // --- Summary Cards ---
    function populateSummaryCards() {
        var stats = TPM_MOCK_DATA.statistics;
        animateCounter('totalMembersValue', stats.totalMembers);
        animateCounter('attendanceValue', stats.attendanceThisWeek);
        animateCounter('titheValue', stats.titheThisMonth, true);
        animateCounter('soulsWonValue', stats.soulsWon);
    }

    function animateCounter(elementId, target, isCurrency) {
        var el = document.getElementById(elementId);
        if (!el) return;

        var duration = 1500;
        var start = 0;
        var startTime = null;

        function step(timestamp) {
            if (!startTime) startTime = timestamp;
            var progress = Math.min((timestamp - startTime) / duration, 1);
            var current = Math.floor(progress * target);

            if (isCurrency) {
                el.textContent = 'GH\u20B5 ' + current.toLocaleString();
            } else {
                el.textContent = current.toLocaleString();
            }

            if (progress < 1) {
                requestAnimationFrame(step);
            }
        }

        requestAnimationFrame(step);
    }

    // --- Filters ---
    function populateFilters() {
        var branchFilter = document.getElementById('branchFilter');
        if (!branchFilter) return;

        TPM_MOCK_DATA.branches.forEach(function(branch) {
            var option = document.createElement('option');
            option.value = branch;
            option.textContent = branch;
            branchFilter.appendChild(option);
        });

        branchFilter.addEventListener('change', function() {
            updateCharts();
            renderCurrentTable();
        });

        var dateRange = document.getElementById('dateRange');
        if (dateRange) {
            dateRange.addEventListener('change', function() {
                updateCharts();
                renderCurrentTable();
            });
        }
    }

    function updateCharts() {
        // For mock, just re-render with same data
        // In a real app, this would filter the data
        if (attendanceChart) {
            attendanceChart.update();
        }
        if (branchChart) {
            branchChart.update();
        }
    }

    // --- Charts ---
    function initAttendanceChart() {
        var ctx = document.getElementById('attendanceChart');
        if (!ctx) return;

        attendanceChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: TPM_MOCK_DATA.attendanceTrends.labels,
                datasets: [{
                    label: 'Attendance',
                    data: TPM_MOCK_DATA.attendanceTrends.data,
                    borderColor: '#D4AF37',
                    backgroundColor: 'rgba(212, 175, 55, 0.1)',
                    borderWidth: 3,
                    pointBackgroundColor: '#D4AF37',
                    pointBorderColor: '#93c5fd',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    tension: 0.3,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        grid: { color: 'rgba(147, 197, 253, 0.1)' },
                        ticks: { color: '#93c5fd', font: { family: "'Montserrat', sans-serif" } }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: '#93c5fd', font: { family: "'Montserrat', sans-serif" } }
                    }
                }
            }
        });
    }

    function initBranchChart() {
        var ctx = document.getElementById('branchChart');
        if (!ctx) return;

        branchChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: TPM_MOCK_DATA.branchComparisons.labels,
                datasets: [{
                    label: 'Attendance',
                    data: TPM_MOCK_DATA.branchComparisons.attendance,
                    backgroundColor: [
                        'rgba(30, 58, 138, 0.85)',
                        'rgba(59, 130, 246, 0.85)',
                        'rgba(147, 197, 253, 0.85)',
                        'rgba(212, 175, 55, 0.85)',
                        'rgba(184, 148, 31, 0.85)',
                        'rgba(30, 58, 138, 0.6)',
                        'rgba(59, 130, 246, 0.6)',
                        'rgba(147, 197, 253, 0.6)'
                    ],
                    borderColor: 'rgba(147, 197, 253, 0.3)',
                    borderWidth: 1,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(147, 197, 253, 0.1)' },
                        ticks: { color: '#93c5fd', font: { family: "'Montserrat', sans-serif" } }
                    },
                    x: {
                        grid: { display: false },
                        ticks: {
                            color: '#93c5fd',
                            font: { family: "'Montserrat', sans-serif", size: 11 },
                            maxRotation: 45
                        }
                    }
                }
            }
        });
    }

    // --- Data Tables ---
    var currentTableTab = 'loucs';

    function initDataTables() {
        var tabs = document.querySelectorAll('.table-tab');
        tabs.forEach(function(tab) {
            tab.addEventListener('click', function() {
                tabs.forEach(function(t) { t.classList.remove('active'); });
                tab.classList.add('active');
                currentTableTab = tab.getAttribute('data-table');
                renderCurrentTable();
            });
        });

        // Render default tab
        renderCurrentTable();
    }

    function renderCurrentTable() {
        var tableHead = document.getElementById('dataTableHead');
        var tableBody = document.getElementById('dataTableBody');
        if (!tableHead || !tableBody) return;

        var branchFilter = document.getElementById('branchFilter');
        var selectedBranch = branchFilter ? branchFilter.value : 'All Branches';

        switch (currentTableTab) {
            case 'loucs':
                renderAttendanceTable(tableHead, tableBody, TPM_MOCK_DATA.loucsReport, 'LOUCS Report', selectedBranch);
                break;
            case 'basenia':
                renderAttendanceTable(tableHead, tableBody, TPM_MOCK_DATA.baseniaReport, 'Basenia', selectedBranch);
                break;
            case 'friday':
                renderAttendanceTable(tableHead, tableBody, TPM_MOCK_DATA.fridayServiceReport, 'Friday Service', selectedBranch);
                break;
            case 'general':
                renderAttendanceTable(tableHead, tableBody, TPM_MOCK_DATA.generalMeetingReport, 'General Meeting', selectedBranch);
                break;
            case 'tithe':
                renderTitheTable(tableHead, tableBody, selectedBranch);
                break;
            case 'souls':
                renderSoulsTable(tableHead, tableBody, selectedBranch);
                break;
        }
    }

    function renderAttendanceTable(thead, tbody, data, title, branchFilter) {
        thead.innerHTML = '<tr><th>Date</th><th>Branch</th><th>Attendance</th><th>Notes</th></tr>';

        var filtered = branchFilter === 'All Branches' ? data :
            data.filter(function(r) { return r.branch === branchFilter; });

        if (filtered.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color: var(--text-gray);">No data available.</td></tr>';
            return;
        }

        tbody.innerHTML = filtered.map(function(row) {
            return '<tr><td>' + row.date + '</td><td>' + row.branch +
                '</td><td>' + row.attendance + '</td><td>' + (row.notes || '-') + '</td></tr>';
        }).join('');
    }

    function renderTitheTable(thead, tbody, branchFilter) {
        thead.innerHTML = '<tr><th>Date</th><th>Branch</th><th>Amount (GH\u20B5)</th><th>Payer Count</th></tr>';

        var data = TPM_MOCK_DATA.titheRecords;
        var filtered = branchFilter === 'All Branches' ? data :
            data.filter(function(r) { return r.branch === branchFilter; });

        if (filtered.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color: var(--text-gray);">No data available.</td></tr>';
            return;
        }

        tbody.innerHTML = filtered.map(function(row) {
            return '<tr><td>' + row.date + '</td><td>' + row.branch +
                '</td><td>' + row.amount.toLocaleString() + '</td><td>' + row.payerCount + '</td></tr>';
        }).join('');
    }

    function renderSoulsTable(thead, tbody, branchFilter) {
        thead.innerHTML = '<tr><th>Date</th><th>Branch</th><th>Souls Won</th><th>Led By</th></tr>';

        var data = TPM_MOCK_DATA.soulsWonRecords;
        var filtered = branchFilter === 'All Branches' ? data :
            data.filter(function(r) { return r.branch === branchFilter; });

        if (filtered.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color: var(--text-gray);">No data available.</td></tr>';
            return;
        }

        tbody.innerHTML = filtered.map(function(row) {
            return '<tr><td>' + row.date + '</td><td>' + row.branch +
                '</td><td>' + row.count + '</td><td>' + row.leadBy + '</td></tr>';
        }).join('');
    }

    // --- Data Entry Form ---
    function initDataEntryForm() {
        var form = document.getElementById('dataEntryForm');
        if (!form) return;

        // Populate dropdowns
        var meetingType = document.getElementById('entryMeetingType');
        if (meetingType) {
            TPM_MOCK_DATA.meetingTypes.forEach(function(type) {
                var option = document.createElement('option');
                option.value = type;
                option.textContent = type;
                meetingType.appendChild(option);
            });
        }

        var entryBranch = document.getElementById('entryBranch');
        if (entryBranch) {
            TPM_MOCK_DATA.branches.forEach(function(branch) {
                var option = document.createElement('option');
                option.value = branch;
                option.textContent = branch;
                entryBranch.appendChild(option);
            });
        }

        form.addEventListener('submit', function(e) {
            e.preventDefault();
            window.TPMFormUtils.clearMessages(form);

            var type = form.querySelector('[name="meetingType"]').value;
            var branch = form.querySelector('[name="entryBranch"]').value;
            var date = form.querySelector('[name="entryDate"]').value;
            var attendance = form.querySelector('[name="entryAttendance"]').value;

            if (!type || !branch || !date) {
                window.TPMFormUtils.showFormError(form, 'Please fill in all required fields.');
                return;
            }

            window.TPMFormUtils.showFormSuccess(form, 'Record submitted successfully!');
            form.reset();
            form.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });
    }

    // --- Profile Update Requests Table (Leader Admin) ---
    var currentRequestFilter = 'all';

    function initRequestsTable() {
        var filterTabs = document.querySelectorAll('.request-filter-tab');
        filterTabs.forEach(function(tab) {
            tab.addEventListener('click', function() {
                filterTabs.forEach(function(t) { t.classList.remove('active'); });
                tab.classList.add('active');
                currentRequestFilter = tab.getAttribute('data-filter');
                renderRequestsTable();
            });
        });

        renderRequestsTable();
    }

    function renderRequestsTable() {
        var tbody = document.getElementById('requestsTableBody');
        if (!tbody) return;

        var requests = TPM_MOCK_DATA.profileUpdateRequests;

        if (currentRequestFilter !== 'all') {
            requests = requests.filter(function(r) {
                return r.status.toLowerCase() === currentRequestFilter;
            });
        }

        if (requests.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color: var(--text-gray);">No requests found.</td></tr>';
            return;
        }

        tbody.innerHTML = requests.map(function(req) {
            var statusClass = req.status.toLowerCase();
            var actions = '';
            if (req.status === 'Pending') {
                actions = '<button class="action-btn approve" onclick="window.TPMStats.handleRequest(' + req.id + ', \'Approved\')">Approve</button> ' +
                    '<button class="action-btn reject" onclick="window.TPMStats.handleRequest(' + req.id + ', \'Rejected\')">Reject</button>';
            } else {
                actions = '<span class="status-badge ' + statusClass + '">' + req.status + '</span>';
            }

            return '<tr>' +
                '<td>' + escapeHtml(req.memberName) + '</td>' +
                '<td>' + escapeHtml(req.field) + '</td>' +
                '<td>' + escapeHtml(req.oldValue) + '</td>' +
                '<td>' + escapeHtml(req.newValue) + '</td>' +
                '<td>' + req.date + '</td>' +
                '<td><span class="status-badge ' + statusClass + '">' + req.status + '</span></td>' +
                '<td>' + actions + '</td>' +
                '</tr>';
        }).join('');
    }

    function handleRequest(requestId, newStatus) {
        var request = TPM_MOCK_DATA.profileUpdateRequests.find(function(r) { return r.id === requestId; });
        if (request) {
            request.status = newStatus;
            renderRequestsTable();
        }
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    // Expose for onclick handlers
    window.TPMStats = {
        handleRequest: handleRequest
    };

    // --- Initialize ---
    document.addEventListener('DOMContentLoaded', function() {
        initStatisticsDashboard();
    });

})();
