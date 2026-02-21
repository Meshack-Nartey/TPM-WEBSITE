// ===================================
// Mock Data for TPM Church Database
// ===================================

var TPM_MOCK_DATA = {

    branches: [
        'Accra Central', 'Kumasi', 'Takoradi', 'Tamale',
        'Cape Coast', 'Sunyani', 'Ho', 'Koforidua'
    ],

    departments: [
        'Choir', 'Ushers', 'Media', 'Youth', 'Children',
        'Protocol', 'Prayer Warriors', 'Evangelism', 'Welfare'
    ],

    membershipStatuses: [
        'New Convert', 'Regular Member', 'Worker', 'Leader'
    ],

    genders: ['Male', 'Female'],

    meetingTypes: [
        'LOUCS Report', 'Basenia', 'Friday Service',
        'General Meeting', 'Tithe Collection', 'Souls Won'
    ],

    members: [
        {
            id: 1, firstName: 'Kwame', lastName: 'Mensah',
            dob: '1990-05-15', gender: 'Male',
            phone: '+233241234567', email: 'kwame.mensah@example.com',
            address: '123 Independence Ave, Accra',
            branch: 'Accra Central', department: 'Choir',
            dateJoined: '2020-01-15', membershipStatus: 'Worker',
            emergencyContactName: 'Ama Mensah',
            emergencyContactPhone: '+233209876543',
            profilePhoto: null
        },
        {
            id: 2, firstName: 'Abena', lastName: 'Osei',
            dob: '1995-08-22', gender: 'Female',
            phone: '+233551234567', email: 'abena.osei@example.com',
            address: '45 Kumasi Road, Kumasi',
            branch: 'Kumasi', department: 'Media',
            dateJoined: '2021-03-10', membershipStatus: 'Regular Member',
            emergencyContactName: 'Kofi Osei',
            emergencyContactPhone: '+233201234567',
            profilePhoto: null
        },
        {
            id: 3, firstName: 'Yaw', lastName: 'Boateng',
            dob: '1988-12-03', gender: 'Male',
            phone: '+233271234567', email: 'yaw.boateng@example.com',
            address: '78 Beach Road, Takoradi',
            branch: 'Takoradi', department: 'Ushers',
            dateJoined: '2019-06-20', membershipStatus: 'Leader',
            emergencyContactName: 'Akua Boateng',
            emergencyContactPhone: '+233241111222',
            profilePhoto: null
        },
        {
            id: 4, firstName: 'Efua', lastName: 'Asante',
            dob: '1998-02-14', gender: 'Female',
            phone: '+233501234567', email: 'efua.asante@example.com',
            address: '12 Castle Road, Cape Coast',
            branch: 'Cape Coast', department: 'Youth',
            dateJoined: '2023-01-08', membershipStatus: 'New Convert',
            emergencyContactName: 'James Asante',
            emergencyContactPhone: '+233209999888',
            profilePhoto: null
        },
        {
            id: 5, firstName: 'Kofi', lastName: 'Adjei',
            dob: '1985-07-19', gender: 'Male',
            phone: '+233261234567', email: 'kofi.adjei@example.com',
            address: '56 Market Street, Tamale',
            branch: 'Tamale', department: 'Evangelism',
            dateJoined: '2018-11-01', membershipStatus: 'Worker',
            emergencyContactName: 'Sarah Adjei',
            emergencyContactPhone: '+233241234000',
            profilePhoto: null
        },
        {
            id: 6, firstName: 'Adwoa', lastName: 'Danso',
            dob: '1993-04-30', gender: 'Female',
            phone: '+233531234567', email: 'adwoa.danso@example.com',
            address: '89 Ring Road, Sunyani',
            branch: 'Sunyani', department: 'Prayer Warriors',
            dateJoined: '2022-05-15', membershipStatus: 'Regular Member',
            emergencyContactName: 'Daniel Danso',
            emergencyContactPhone: '+233201234999',
            profilePhoto: null
        },
        {
            id: 7, firstName: 'Kwesi', lastName: 'Amponsah',
            dob: '1991-09-11', gender: 'Male',
            phone: '+233241239999', email: 'kwesi.amponsah@example.com',
            address: '34 Ho Main Road, Ho',
            branch: 'Ho', department: 'Protocol',
            dateJoined: '2020-08-20', membershipStatus: 'Worker',
            emergencyContactName: 'Mary Amponsah',
            emergencyContactPhone: '+233551239999',
            profilePhoto: null
        },
        {
            id: 8, firstName: 'Akosua', lastName: 'Frimpong',
            dob: '1997-01-25', gender: 'Female',
            phone: '+233271239999', email: 'akosua.frimpong@example.com',
            address: '67 New Juaben, Koforidua',
            branch: 'Koforidua', department: 'Welfare',
            dateJoined: '2023-09-01', membershipStatus: 'New Convert',
            emergencyContactName: 'Grace Frimpong',
            emergencyContactPhone: '+233241234888',
            profilePhoto: null
        },
        {
            id: 9, firstName: 'Nana', lastName: 'Owusu',
            dob: '1986-06-08', gender: 'Male',
            phone: '+233501239999', email: 'nana.owusu@example.com',
            address: '15 Osu Oxford Street, Accra',
            branch: 'Accra Central', department: 'Media',
            dateJoined: '2017-04-12', membershipStatus: 'Leader',
            emergencyContactName: 'Rita Owusu',
            emergencyContactPhone: '+233261234777',
            profilePhoto: null
        },
        {
            id: 10, firstName: 'Esi', lastName: 'Turkson',
            dob: '1994-11-17', gender: 'Female',
            phone: '+233261239999', email: 'esi.turkson@example.com',
            address: '23 Adum, Kumasi',
            branch: 'Kumasi', department: 'Children',
            dateJoined: '2021-07-30', membershipStatus: 'Regular Member',
            emergencyContactName: 'Joseph Turkson',
            emergencyContactPhone: '+233531234666',
            profilePhoto: null
        }
    ],

    profileUpdateRequests: [
        {
            id: 1, memberId: 1, memberName: 'Kwame Mensah',
            field: 'Phone', oldValue: '+233241234567', newValue: '+233241234999',
            status: 'Pending', date: '2026-02-10'
        },
        {
            id: 2, memberId: 2, memberName: 'Abena Osei',
            field: 'Address', oldValue: '45 Kumasi Road, Kumasi', newValue: '78 New Kumasi Road, Kumasi',
            status: 'Approved', date: '2026-02-05'
        },
        {
            id: 3, memberId: 3, memberName: 'Yaw Boateng',
            field: 'Department', oldValue: 'Ushers', newValue: 'Protocol',
            status: 'Rejected', date: '2026-02-01'
        },
        {
            id: 4, memberId: 5, memberName: 'Kofi Adjei',
            field: 'Email', oldValue: 'kofi.adjei@example.com', newValue: 'kofi.a@newmail.com',
            status: 'Pending', date: '2026-02-12'
        },
        {
            id: 5, memberId: 4, memberName: 'Efua Asante',
            field: 'Emergency Contact Phone', oldValue: '+233209999888', newValue: '+233209999111',
            status: 'Pending', date: '2026-02-13'
        },
        {
            id: 6, memberId: 7, memberName: 'Kwesi Amponsah',
            field: 'Branch', oldValue: 'Ho', newValue: 'Accra Central',
            status: 'Approved', date: '2026-01-28'
        }
    ],

    statistics: {
        totalMembers: 1247,
        attendanceThisWeek: 892,
        titheThisMonth: 45600,
        soulsWon: 23
    },

    attendanceTrends: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        data: [780, 820, 850, 790, 860, 900, 870, 920, 890, 940, 910, 892]
    },

    branchComparisons: {
        labels: ['Accra Central', 'Kumasi', 'Takoradi', 'Tamale', 'Cape Coast', 'Sunyani', 'Ho', 'Koforidua'],
        attendance: [320, 210, 145, 98, 75, 44, 55, 40],
        tithe: [12500, 8900, 6200, 3800, 2900, 2100, 1800, 1400]
    },

    loucsReport: [
        { date: '2026-02-09', branch: 'Accra Central', attendance: 285, notes: 'Special service' },
        { date: '2026-02-09', branch: 'Kumasi', attendance: 192, notes: '' },
        { date: '2026-02-09', branch: 'Takoradi', attendance: 134, notes: '' },
        { date: '2026-02-09', branch: 'Tamale', attendance: 87, notes: 'Guest speaker' },
        { date: '2026-02-02', branch: 'Accra Central', attendance: 270, notes: '' },
        { date: '2026-02-02', branch: 'Kumasi', attendance: 185, notes: '' },
        { date: '2026-02-02', branch: 'Takoradi', attendance: 128, notes: '' },
        { date: '2026-02-02', branch: 'Tamale', attendance: 92, notes: '' }
    ],

    baseniaReport: [
        { date: '2026-02-08', branch: 'Accra Central', attendance: 145, notes: '' },
        { date: '2026-02-08', branch: 'Kumasi', attendance: 98, notes: '' },
        { date: '2026-02-08', branch: 'Takoradi', attendance: 67, notes: '' },
        { date: '2026-02-01', branch: 'Accra Central', attendance: 152, notes: 'Youth outreach' },
        { date: '2026-02-01', branch: 'Kumasi', attendance: 101, notes: '' },
        { date: '2026-02-01', branch: 'Takoradi', attendance: 72, notes: '' }
    ],

    fridayServiceReport: [
        { date: '2026-02-07', branch: 'Accra Central', attendance: 210, notes: 'Love Therapy' },
        { date: '2026-02-07', branch: 'Kumasi', attendance: 156, notes: '' },
        { date: '2026-02-07', branch: 'Takoradi', attendance: 98, notes: '' },
        { date: '2026-01-31', branch: 'Accra Central', attendance: 198, notes: '' },
        { date: '2026-01-31', branch: 'Kumasi', attendance: 149, notes: '' },
        { date: '2026-01-31', branch: 'Takoradi', attendance: 105, notes: '' }
    ],

    generalMeetingReport: [
        { date: '2026-02-10', branch: 'Accra Central', attendance: 320, notes: 'Monthly meeting' },
        { date: '2026-02-10', branch: 'Kumasi', attendance: 210, notes: '' },
        { date: '2026-01-13', branch: 'Accra Central', attendance: 305, notes: 'Annual planning' },
        { date: '2026-01-13', branch: 'Kumasi', attendance: 198, notes: '' }
    ],

    titheRecords: [
        { date: '2026-02-09', branch: 'Accra Central', amount: 12500, payerCount: 185 },
        { date: '2026-02-09', branch: 'Kumasi', amount: 8900, payerCount: 132 },
        { date: '2026-02-09', branch: 'Takoradi', amount: 6200, payerCount: 89 },
        { date: '2026-02-09', branch: 'Tamale', amount: 3800, payerCount: 56 },
        { date: '2026-02-02', branch: 'Accra Central', amount: 11800, payerCount: 178 },
        { date: '2026-02-02', branch: 'Kumasi', amount: 8500, payerCount: 125 },
        { date: '2026-02-02', branch: 'Takoradi', amount: 5900, payerCount: 82 },
        { date: '2026-02-02', branch: 'Tamale', amount: 3500, payerCount: 51 }
    ],

    soulsWonRecords: [
        { date: '2026-02-09', branch: 'Accra Central', count: 8, leadBy: 'Evangelism Team' },
        { date: '2026-02-09', branch: 'Kumasi', count: 5, leadBy: 'Youth Ministry' },
        { date: '2026-02-09', branch: 'Takoradi', count: 3, leadBy: 'Outreach Team' },
        { date: '2026-02-09', branch: 'Tamale', count: 2, leadBy: 'Prayer Warriors' },
        { date: '2026-02-02', branch: 'Accra Central', count: 6, leadBy: 'Evangelism Team' },
        { date: '2026-02-02', branch: 'Kumasi', count: 4, leadBy: 'Youth Ministry' },
        { date: '2026-02-02', branch: 'Takoradi', count: 2, leadBy: 'Outreach Team' }
    ]
};
