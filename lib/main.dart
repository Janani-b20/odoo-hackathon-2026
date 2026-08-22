import 'package:flutter/material.dart';
import 'services/dayflow_api.dart';

void main() => runApp(const DayflowApp());

class DayflowApp extends StatefulWidget {
  const DayflowApp({super.key});
  @override
  State<DayflowApp> createState() => _DayflowAppState();
}

class _DayflowAppState extends State<DayflowApp> {
  bool _signedIn = false;
  bool _isAdmin = true;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Dayflow',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5CE2)),
      fontFamily: 'Arial',
    ),
    home: _signedIn
        ? DashboardPage(isAdmin: _isAdmin, onLogout: () => setState(() => _signedIn = false))
        : LoginPage(onSignIn: (isAdmin) => setState(() { _isAdmin = isAdmin; _signedIn = true; })),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onSignIn});
  final ValueChanged<bool> onSignIn;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isAdmin = true;
  bool _hidden = true;
  bool _loading = false;
  final _email = TextEditingController(text: 'aarav@dayflow.com');
  final _password = TextEditingController(text: 'dayflow123');
  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      final result = await DayflowApi().login(_email.text.trim());
      final user = result['user'] as Map<String, dynamic>;
      if (mounted) widget.onSignIn(user['role'] == 'admin');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;
    return Scaffold(body: SafeArea(child: Row(children: [
      if (wide) const Expanded(child: _LoginIntro()),
      Expanded(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(32), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 390), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!wide) const _BrandDark(),
        if (!wide) const SizedBox(height: 38),
        const Text('Welcome back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.8)),
        const SizedBox(height: 8), const Text('Sign in to manage your workday.', style: TextStyle(color: Color(0xFF77788B))),
        const SizedBox(height: 28),
        Container(decoration: BoxDecoration(color: const Color(0xFFF2F2F8), borderRadius: BorderRadius.circular(11)), padding: const EdgeInsets.all(4), child: Row(children: [
          Expanded(child: _RoleOption(label: 'Admin / HR', active: _isAdmin, onTap: () => setState(() { _isAdmin = true; _email.text = 'aarav@dayflow.com'; }))),
          Expanded(child: _RoleOption(label: 'Employee', active: !_isAdmin, onTap: () => setState(() { _isAdmin = false; _email.text = 'neha@dayflow.com'; }))),
        ])),
        const SizedBox(height: 24),
        const Text('Work email', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), const SizedBox(height: 8),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'you@company.com', border: OutlineInputBorder(), prefixIcon: Icon(Icons.mail_outline_rounded))),
        const SizedBox(height: 18), const Text('Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), const SizedBox(height: 8),
        TextField(controller: _password, obscureText: _hidden, decoration: InputDecoration(hintText: 'Enter your password', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _hidden = !_hidden), icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
        const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot password?'))),
        const SizedBox(height: 10), SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: _loading ? null : _signIn, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B5CE2)), child: Text(_loading ? 'Signing in...' : 'Sign in'))),
        const SizedBox(height: 20), const Center(child: Text('Demo mode - no credentials are stored.', style: TextStyle(fontSize: 11, color: Color(0xFF8B8C9D)))),
      ]))))),
    ])));
  }
}

class _RoleOption extends StatelessWidget { const _RoleOption({required this.label, required this.active, required this.onTap}); final String label; final bool active; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: active ? const [BoxShadow(color: Color(0x12000000), blurRadius: 5)] : null), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? const Color(0xFF343449) : const Color(0xFF8A8B9C))))); }
class _BrandDark extends StatelessWidget { const _BrandDark(); @override Widget build(BuildContext context) => const Row(children: [DecoratedBox(decoration: BoxDecoration(color: Color(0xFF5B5CE2), borderRadius: BorderRadius.all(Radius.circular(9))), child: SizedBox(width: 34, height: 34, child: Icon(Icons.bolt_rounded, color: Colors.white))), SizedBox(width: 10), Text('dayflow', style: TextStyle(color: Color(0xFF17172B), fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -.8))]); }
class _LoginIntro extends StatelessWidget { const _LoginIntro(); @override Widget build(BuildContext context) => Container(color: const Color(0xFF17172B), padding: const EdgeInsets.all(56), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ _Brand(), Spacer(), Text('Every workday,\nperfectly aligned.', style: TextStyle(color: Colors.white, fontSize: 42, height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1.4)), SizedBox(height: 16), Text('One place for people, time off, attendance and payroll.', style: TextStyle(color: Color(0xFFB7B8CC), fontSize: 16, height: 1.5)), Spacer(), Text('DAYFLOW HRMS', style: TextStyle(color: Color(0xFF8586A3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2))])); }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.isAdmin, required this.onLogout});
  final bool isAdmin;
  final VoidCallback onLogout;
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selected = 0;
  static const adminNav = [
    ('Overview', Icons.grid_view_rounded),
    ('Attendance', Icons.calendar_month_rounded),
    ('Leave', Icons.beach_access_rounded),
    ('People', Icons.people_alt_rounded),
    ('Payroll', Icons.account_balance_wallet_rounded),
    ('Reports', Icons.insert_chart_outlined_rounded),
  ];
  static const employeeNav = [
    ('Overview', Icons.grid_view_rounded),
    ('Attendance', Icons.calendar_month_rounded),
    ('Leave', Icons.beach_access_rounded),
    ('My profile', Icons.person_outline_rounded),
    ('Payroll', Icons.account_balance_wallet_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1000;
    final nav = widget.isAdmin ? adminNav : employeeNav;
    return Scaffold(
      drawer: desktop
          ? null
          : Drawer(
              child: _Sidebar(selected: selected, onPick: _pick, nav: nav, isAdmin: widget.isAdmin, onLogout: widget.onLogout),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              SizedBox(
                width: 252,
                child: _Sidebar(selected: selected, onPick: _pick, nav: nav, isAdmin: widget.isAdmin, onLogout: widget.onLogout),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(showMenu: !desktop, isAdmin: widget.isAdmin),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1440),
                          child: _Dashboard(selected: selected, isAdmin: widget.isAdmin),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pick(int value) {
    setState(() => selected = value);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onPick, required this.nav, required this.isAdmin, required this.onLogout});
  final int selected;
  final ValueChanged<int> onPick;
  final List<(String, IconData)> nav;
  final bool isAdmin;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF17172B),
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _Brand(),
        ),
        const SizedBox(height: 42),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'WORKSPACE',
            style: TextStyle(
              color: Color(0xFF8586A3),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...nav.asMap().entries.map(
          (e) => _NavItem(
            label: e.value.$1,
            icon: e.value.$2,
            selected: e.key == selected,
            onTap: () => onPick(e.key),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF252540),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFF9A8BFF),
                child: Text(
                  'AS',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdmin ? 'Aarav Sharma' : 'Neha Kapoor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      isAdmin ? 'HR Manager' : 'Product Designer',
                      style: TextStyle(color: Color(0xFFAEB0C8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: onLogout, tooltip: 'Sign out', icon: const Icon(Icons.logout_rounded, color: Color(0xFFAEB0C8), size: 18)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF7773F5),
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.bolt_rounded, color: Colors.white),
        ),
      ),
      SizedBox(width: 10),
      Text(
        'dayflow',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -.8,
        ),
      ),
    ],
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B5CE2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : const Color(0xFFB6B7CB),
            ),
            const SizedBox(width: 13),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFCCCDDD),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showMenu, required this.isAdmin});
  final bool showMenu;
  final bool isAdmin;
  @override
  Widget build(BuildContext context) => Container(
    height: 76,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE9EAF1))),
    ),
    child: Row(
      children: [
        if (showMenu)
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        Expanded(
          child: Container(
            height: 42,
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                SizedBox(width: 14),
                Icon(Icons.search_rounded, color: Color(0xFF9293A7), size: 20),
                SizedBox(width: 9),
                Text(
                  'Search anything...',
                  style: TextStyle(color: Color(0xFF9B9CAF), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _Bell(),
        const SizedBox(width: 14),
        const VerticalDivider(indent: 21, endIndent: 21),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFFFC7A8),
          child: Text(
            'AS',
            style: TextStyle(
              color: Color(0xFF71381C),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Aarav Sharma' : 'Neha Kapoor',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            Text(
              isAdmin ? 'Admin / HR' : 'Employee',
              style: TextStyle(fontSize: 11, color: Color(0xFF8B8C9D)),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Bell extends StatefulWidget {
  const _Bell();
  @override
  State<_Bell> createState() => _BellState();
}

class _BellState extends State<_Bell> {
  bool _hasUnread = true;
  void _showNotifications() {
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: Row(children: [const Text('Notifications'), const Spacer(), TextButton(onPressed: () { setState(() => _hasUnread = false); Navigator.pop(dialogContext); }, child: const Text('Mark all read'))]),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      content: const SizedBox(width: 390, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _NotificationItem(icon: Icons.event_available_rounded, color: Color(0xFF16A36A), title: 'Leave request approved', message: 'Your paid leave for Aug 25 - 27 was approved.', time: '10 min ago'),
        Divider(height: 22),
        _NotificationItem(icon: Icons.access_time_rounded, color: Color(0xFFFF9F43), title: 'Attendance reminder', message: 'Remember to check out when you finish work today.', time: '1 hr ago'),
        Divider(height: 22),
        _NotificationItem(icon: Icons.receipt_long_rounded, color: Color(0xFF5B5CE2), title: 'Salary slip available', message: 'Your August 2026 salary slip is ready to view.', time: 'Yesterday'),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
    ));
  }
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: _showNotifications, child: Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Color(0xFF55566C),
        ),
      ),
      if (_hasUnread) const Positioned(
        right: 9,
        top: 8,
        child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFFF6B6B)),
      ),
    ],
  ));
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.icon, required this.color, required this.title, required this.message, required this.time});
  final IconData icon;
  final Color color;
  final String title, message, time;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 17, color: color)),
    const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF77788B))), const SizedBox(height: 4), Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFFA0A1B0)))])),
  ]);
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.selected, required this.isAdmin});
  final int selected;
  final bool isAdmin;
  @override
  Widget build(BuildContext context) {
    if (selected != 0) return _ModulePage(index: selected, isAdmin: isAdmin);
    return LayoutBuilder(
      builder: (context, box) {
      final wide = box.maxWidth > 850;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good morning, Aarav!',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -.7,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Here’s what’s happening with your team today.',
            style: TextStyle(color: Color(0xFF77788B), fontSize: 14),
          ),
          const SizedBox(height: 25),
          const _Kpis(),
          const SizedBox(height: 24),
          if (wide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _Attendance()),
                SizedBox(width: 22),
                Expanded(flex: 4, child: _Leaves()),
              ],
            )
          else
            const Column(
              children: [_Attendance(), SizedBox(height: 22), _Leaves()],
            ),
          const SizedBox(height: 22),
          if (wide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _Team()),
                SizedBox(width: 22),
                Expanded(flex: 4, child: _Celebrations()),
              ],
            )
          else
            const Column(
              children: [_Team(), SizedBox(height: 22), _Celebrations()],
            ),
        ],
      );
      },
    );
  }
}

class _ModulePage extends StatelessWidget {
  const _ModulePage({required this.index, required this.isAdmin});
  final int index;
  final bool isAdmin;
  static const _titles = [
    ('Overview', 'A clear view of your people operations.'),
    ('Attendance', 'Track daily and weekly attendance across your team.'),
    ('Leave & time off', 'Review employee time-off requests and decisions.'),
    ('Employees', 'Manage employee profiles, job details and documents.'),
    ('Payroll', 'Review salary structures and monthly payroll records.'),
    ('Reports', 'Turn people data into useful, export-ready insights.'),
  ];
  @override
  Widget build(BuildContext context) {
    final item = !isAdmin && index == 3 ? ('My profile', 'Manage your personal information and employment details.') : _titles[index];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(item.$1, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.7)),
      const SizedBox(height: 6),
      Text(item.$2, style: const TextStyle(color: Color(0xFF77788B), fontSize: 14)),
      const SizedBox(height: 24),
      if (index == 1) const _AttendanceModule(),
      if (index == 2) _LeaveModule(isAdmin: isAdmin),
      if (index == 3) isAdmin ? const _PeopleModule() : const _ProfileModule(),
      if (index == 4) const _PayrollModule(),
      if (index == 5) const _ReportsModule(),
    ]);
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.title, required this.action, required this.icon, this.onAction});
  final String title, action;
  final IconData icon;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    const Spacer(),
    FilledButton.icon(onPressed: onAction ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action is ready for backend connection.'))), icon: Icon(icon, size: 17), label: Text(action), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B5CE2), foregroundColor: Colors.white)),
  ]);
}

class _AttendanceModule extends StatefulWidget {
  const _AttendanceModule();
  @override
  State<_AttendanceModule> createState() => _AttendanceModuleState();
}

class _AttendanceModuleState extends State<_AttendanceModule> {
  static const _currentEmployeeId = 2;
  final _api = DayflowApi();
  bool _checkedIn = false;
  bool _loading = true;
  bool _updating = false;
  String _time = '';
  List<List<String>> _attendanceRows = const [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final records = await _api.attendance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final todayRecords = records.cast<Map<String, dynamic>>().where(
        (record) => record['date'] == today,
      ).toList();
      final myRecord = todayRecords.where(
        (record) => record['employee_id'] == _currentEmployeeId,
      ).cast<Map<String, dynamic>>().firstOrNull;
      if (!mounted) return;
      setState(() {
        _checkedIn = myRecord?['check_in'] != null && myRecord?['check_out'] == null;
        _time = _checkedIn ? myRecord!['check_in'].toString() : '';
        _attendanceRows = todayRecords.take(20).map((record) => [
          record['name'].toString(),
          record['date'].toString(),
          record['check_in']?.toString() ?? '—',
          record['check_out']?.toString() ?? '—',
          record['status'].toString(),
        ]).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load attendance: $error')),
      );
    }
  }

  Future<void> _toggleAttendance() async {
    if (_updating || _loading) return;
    setState(() => _updating = true);
    try {
      final response = _checkedIn
          ? await _api.checkOut(_currentEmployeeId)
          : await _api.checkIn(_currentEmployeeId);
      if (!mounted) return;
      final didCheckIn = !_checkedIn;
      final time = response['time'].toString();
      setState(() {
        _checkedIn = didCheckIn;
        _time = didCheckIn ? time : '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(didCheckIn ? 'Checked in successfully at $time.' : 'Checked out successfully at $time.')),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance update failed: $error')));
    } finally {
      if (mounted) setState(() => _updating = false);
      _loadAttendance();
    }
  }
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _ModuleHeader(title: 'Today’s attendance', action: 'Add record', icon: Icons.add_rounded),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: const [_StatusChip('Present', '221', Color(0xFF16A36A)), _StatusChip('Absent', '04', Color(0xFFEC5D81)), _StatusChip('Half-day', '03', Color(0xFFFF9F43)), _StatusChip('On leave', '14', Color(0xFF5B5CE2))]),
      const SizedBox(height: 22),
      _loading ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())) : _ModuleTable(headers: const ['Employee', 'Date', 'Check in', 'Check out', 'Status'], rows: _attendanceRows),
    ]))),
    const SizedBox(height: 18),
    _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [const Icon(Icons.timer_outlined, color: Color(0xFF5B5CE2)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Employee self-service', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(_loading ? 'Loading today’s attendance…' : _checkedIn ? 'Checked in at $_time. Remember to check out when you finish.' : 'Check in to record the start of your workday.', style: const TextStyle(fontSize: 12, color: Color(0xFF77788B)))])), OutlinedButton.icon(onPressed: _loading || _updating ? null : _toggleAttendance, icon: _updating ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(_checkedIn ? Icons.logout_rounded : Icons.login_rounded, size: 17), label: Text(_checkedIn ? 'Check out' : 'Check in'))]))),
  ]);
}

class _LeaveModule extends StatefulWidget {
  const _LeaveModule({required this.isAdmin});
  final bool isAdmin;
  @override
  State<_LeaveModule> createState() => _LeaveModuleState();
}

class _LeaveModuleState extends State<_LeaveModule> {
  final _api = DayflowApi();
  late Future<List<dynamic>> _leaves;

  @override
  void initState() {
    super.initState();
    _reloadLeaves();
  }

  void _reloadLeaves() {
    _leaves = _api.leaves(employeeId: widget.isAdmin ? null : 2);
  }
  Future<void> _applyForLeave() async {
    var type = 'Paid leave';
    final remarks = TextEditingController();
    final submitted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Apply for leave'), content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Leave type', border: OutlineInputBorder()), items: const ['Paid leave', 'Sick leave', 'Unpaid leave'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => type = value ?? type),
      const SizedBox(height: 14), const TextField(readOnly: true, decoration: InputDecoration(labelText: 'Date range', hintText: '25 Aug 2026 - 27 Aug 2026', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today_outlined))),
      const SizedBox(height: 14), TextField(controller: remarks, maxLines: 3, decoration: const InputDecoration(labelText: 'Remarks', hintText: 'Reason for time off', border: OutlineInputBorder())),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Submit request'))]));
    if (submitted == true && mounted) {
      try {
        await _api.applyForLeave(employeeId: 2, leaveType: type, startDate: '2026-08-25', endDate: '2026-08-27', remarks: remarks.text);
        if (mounted) {
          setState(_reloadLeaves);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request submitted as Pending.')));
        }
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave submission failed: $error')));
      }
    }
    remarks.dispose();
  }
  @override
  Widget build(BuildContext context) => _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModuleHeader(title: widget.isAdmin ? 'Leave requests' : 'My leave requests', action: 'Apply for leave', icon: Icons.add_rounded, onAction: _applyForLeave), const SizedBox(height: 20),
    FutureBuilder<List<dynamic>>(future: _leaves, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
      if (snapshot.hasError) return Text('Could not load leave requests: ${snapshot.error}', style: const TextStyle(color: Color(0xFFEC5D81)));
      final leaves = snapshot.data!.cast<Map<String, dynamic>>();
      final rows = leaves.map((leave) => [leave['name'].toString(), leave['leave_type'].toString(), '${leave['start_date']} – ${leave['end_date']}', leave['remarks']?.toString() ?? '—', leave['status'].toString()]).toList();
      final pending = leaves.where((leave) => leave['status'] == 'Pending').toList();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ModuleTable(headers: const ['Employee', 'Leave type', 'Dates', 'Remarks', 'Status'], rows: rows),
        const SizedBox(height: 16), const Text('Admins can approve or reject requests; employees immediately see the updated status.', style: TextStyle(color: Color(0xFF77788B), fontSize: 12)),
        if (widget.isAdmin) ...[
          const SizedBox(height: 22),
          Row(children: [Text('${pending.length} pending approvals', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), const Spacer(), const Icon(Icons.pending_actions_outlined, color: Color(0xFFFF9F43), size: 19)]),
          ...pending.map((leave) => _ApprovalItem(name: leave['name'].toString(), detail: '${leave['leave_type']} · ${leave['start_date']} – ${leave['end_date']}', onApprove: () => _decide(leave, true), onReject: () => _decide(leave, false))),
        ],
      ]);
    }),
  ])));

  Future<void> _decide(Map<String, dynamic> leave, bool approved) async {
    try {
      await _api.updateLeaveStatus(leave['id'] as int, approved ? 'Approved' : 'Rejected');
      if (!mounted) return;
      setState(_reloadLeaves);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${approved ? 'Approved' : 'Rejected'} ${leave['name']}’s leave request.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave update failed: $error')));
    }
  }
}

class _ApprovalItem extends StatelessWidget {
  const _ApprovalItem({required this.name, required this.detail, required this.onApprove, required this.onReject});
  final String name, detail;
  final VoidCallback onApprove, onReject;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF9F9FC), borderRadius: BorderRadius.circular(10)), child: Row(children: [
    CircleAvatar(radius: 17, backgroundColor: const Color(0xFFD6C6FF), child: Text(name.split(' ').map((part) => part[0]).join(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
    const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), Text(detail, style: const TextStyle(fontSize: 11, color: Color(0xFF77788B)))])),
    IconButton(onPressed: onReject, tooltip: 'Reject', icon: const Icon(Icons.close_rounded, color: Color(0xFFEC5D81))),
    IconButton(onPressed: onApprove, tooltip: 'Approve', icon: const Icon(Icons.check_rounded, color: Color(0xFF16A36A))),
  ]));
}

class _PeopleModule extends StatefulWidget {
  const _PeopleModule();
  @override
  State<_PeopleModule> createState() => _PeopleModuleState();
}

class _PeopleModuleState extends State<_PeopleModule> {
  late final Future<List<dynamic>> _employees;
  @override
  void initState() { super.initState(); _employees = DayflowApi().employees(); }
  @override
  Widget build(BuildContext context) => _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _ModuleHeader(title: 'All employees', action: 'Add employee', icon: Icons.person_add_alt_1_rounded), const SizedBox(height: 20),
    FutureBuilder<List<dynamic>>(future: _employees, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
      if (snapshot.hasError) return Text('Could not load employees: ${snapshot.error}', style: const TextStyle(color: Color(0xFFEC5D81)));
      final rows = snapshot.data!.map((entry) { final employee = entry as Map<String, dynamic>; return [employee['name'].toString(), employee['employee_id'].toString(), employee['department'].toString(), employee['designation'].toString(), 'View']; }).toList();
      return _ModuleTable(headers: const ['Employee', 'Employee ID', 'Department', 'Role', 'Profile'], rows: rows);
    }),
    const SizedBox(height: 16), const Text('Profiles include personal and job details, salary structure, documents, and profile photos. Employees can update only their address, phone, and photo.', style: TextStyle(color: Color(0xFF77788B), fontSize: 12)),
  ])));
}

class _ProfileModule extends StatelessWidget {
  const _ProfileModule();
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final wide = box.maxWidth > 800;
    final details = _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _ModuleHeader(title: 'Personal details', action: 'Edit profile', icon: Icons.edit_outlined), const SizedBox(height: 20),
      const _ProfileRow('Email', 'neha@dayflow.com'), const Divider(height: 24), const _ProfileRow('Phone', '+91 98765 43210'), const Divider(height: 24), const _ProfileRow('Address', 'Bengaluru, Karnataka'),
    ])));
    final job = _Panel(child: Padding(padding: const EdgeInsets.all(20), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Job details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(height: 20), _ProfileRow('Employee ID', 'DF-1024'), Divider(height: 24), _ProfileRow('Department', 'Product'), Divider(height: 24), _ProfileRow('Designation', 'Product Designer'), Divider(height: 24), _ProfileRow('Joining date', '18 March 2024'),
    ])));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Panel(child: Padding(padding: const EdgeInsets.all(20), child: const Row(children: [CircleAvatar(radius: 30, backgroundColor: Color(0xFFFED2B6), child: Text('NK', style: TextStyle(fontWeight: FontWeight.w800))), SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Neha Kapoor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), SizedBox(height: 3), Text('Product Designer · Product', style: TextStyle(color: Color(0xFF77788B), fontSize: 13))])]))),
      const SizedBox(height: 18),
      if (wide) Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: details), const SizedBox(width: 18), Expanded(child: job)]) else Column(children: [details, const SizedBox(height: 18), job]),
    ]);
  });
}
class _ProfileRow extends StatelessWidget { const _ProfileRow(this.label, this.value); final String label, value; @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF77788B)))), Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))]); }

class _PayrollModule extends StatefulWidget {
  const _PayrollModule();
  @override
  State<_PayrollModule> createState() => _PayrollModuleState();
}

class _PayrollModuleState extends State<_PayrollModule> {
  late final Future<List<dynamic>> _payroll;
  @override
  void initState() { super.initState(); _payroll = DayflowApi().payroll(); }
  @override
  Widget build(BuildContext context) => _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _ModuleHeader(title: 'Payroll overview', action: 'Update payroll', icon: Icons.edit_calendar_rounded), const SizedBox(height: 20),
    FutureBuilder<List<dynamic>>(future: _payroll, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
      if (snapshot.hasError) return Text('Could not load payroll: ${snapshot.error}', style: const TextStyle(color: Color(0xFFEC5D81)));
      final rows = snapshot.data!.map((entry) { final payroll = entry as Map<String, dynamic>; return [payroll['name'].toString(), 'August 2026', '₹${payroll['base_salary']}', '₹${payroll['deductions']}', '₹${payroll['net_pay']}']; }).toList();
      return _ModuleTable(headers: const ['Employee', 'Month', 'Base salary', 'Deductions', 'Net pay'], rows: rows);
    }),
    const SizedBox(height: 16), const Text('Payroll is read-only for employees. HR and admins can review and update each employee’s salary structure.', style: TextStyle(color: Color(0xFF77788B), fontSize: 12)),
  ])));
}

class _ReportsModule extends StatelessWidget {
  const _ReportsModule();
  @override
  Widget build(BuildContext context) => GridView.count(crossAxisCount: MediaQuery.sizeOf(context).width > 750 ? 3 : 1, mainAxisSpacing: 16, crossAxisSpacing: 16, shrinkWrap: true, childAspectRatio: 1.45, physics: const NeverScrollableScrollPhysics(), children: const [_ReportCard(Icons.calendar_month_rounded, 'Attendance report', 'Daily, weekly and team attendance'), _ReportCard(Icons.receipt_long_rounded, 'Salary slips', 'Monthly payroll statements'), _ReportCard(Icons.insights_rounded, 'People analytics', 'Headcount and leave insights')]);
}

class _StatusChip extends StatelessWidget { const _StatusChip(this.label, this.value, this.color); final String label, value; final Color color; @override Widget build(BuildContext context) => Container(width: 150, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 24)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF77788B)))])); }
class _ModuleTable extends StatelessWidget { const _ModuleTable({required this.headers, required this.rows}); final List<String> headers; final List<List<String>> rows; @override Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7F7FB)), columns: headers.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)))).toList(), rows: rows.map((r) => DataRow(cells: r.map((c) => DataCell(Text(c, style: const TextStyle(fontSize: 12)))).toList())).toList())); }
class _ReportCard extends StatelessWidget { const _ReportCard(this.icon, this.title, this.description); final IconData icon; final String title, description; @override Widget build(BuildContext context) => _Panel(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF5B5CE2), size: 26), const Spacer(), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), const SizedBox(height: 4), Text(description, style: const TextStyle(color: Color(0xFF77788B), fontSize: 12)), const SizedBox(height: 12), const Text('Generate report →', style: TextStyle(color: Color(0xFF5B5CE2), fontWeight: FontWeight.w700, fontSize: 12))]))); }

class _Kpis extends StatelessWidget {
  const _Kpis();
  @override
  Widget build(BuildContext context) {
    const data = [
      (
        'Total employees',
        '248',
        '+12 this month',
        Icons.groups_rounded,
        Color(0xFF5B5CE2),
      ),
      (
        'Present today',
        '221',
        '89.1% attendance',
        Icons.check_circle_rounded,
        Color(0xFF16A36A),
      ),
      (
        'On leave',
        '14',
        '6 requests pending',
        Icons.beach_access_rounded,
        Color(0xFFFF9F43),
      ),
      (
        'Open positions',
        '08',
        '3 interviews today',
        Icons.work_outline_rounded,
        Color(0xFFEC5D81),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 290,
        mainAxisExtent: 142,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final d = data[i];
        return _Panel(
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                  color: d.$5.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(d.$4, color: d.$5, size: 20),
                    ),
                    const Icon(Icons.more_horiz, color: Color(0xFFA8A9B8)),
                  ],
                ),
                const Spacer(),
                Text(
                  d.$2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${d.$1}  •  ${d.$3}',
                  style: const TextStyle(
                    color: Color(0xFF77788B),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEAEBF2)),
    ),
    child: child,
  );
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.title, this.action);
  final String title, action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      Text(
        action,
        style: const TextStyle(
          color: Color(0xFF5B5CE2),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class _Attendance extends StatelessWidget {
  const _Attendance();
  @override
  Widget build(BuildContext context) => _Panel(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Attendance overview', 'View report  →'),
          const SizedBox(height: 8),
          const Text(
            '22 August 2026',
            style: TextStyle(color: Color(0xFF858699), fontSize: 12),
          ),
          const SizedBox(height: 26),
          const Row(
            children: [
              Expanded(child: _AStat('Present', '221', Color(0xFF16A36A))),
              Expanded(child: _AStat('Late', '09', Color(0xFFFFA34D))),
              Expanded(child: _AStat('Absent', '04', Color(0xFFEC5D81))),
              Expanded(child: _AStat('Remote', '14', Color(0xFF5B5CE2))),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: .891,
              minHeight: 9,
              backgroundColor: Color(0xFFF0F0F5),
              color: Color(0xFF16A36A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '89.1% of your team has checked in today',
            style: TextStyle(color: Color(0xFF77788B), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _AStat extends StatelessWidget {
  const _AStat(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF77788B), fontSize: 12),
      ),
    ],
  );
}

class _Leaves extends StatelessWidget {
  const _Leaves();
  @override
  Widget build(BuildContext context) => _Panel(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Leave requests', 'See all  →'),
          const SizedBox(height: 18),
          const _Request(
            'MS',
            'Meera Shah',
            'Annual leave',
            'Aug 25 - 27',
            Color(0xFFFFC5C5),
          ),
          const Divider(height: 25),
          const _Request(
            'RK',
            'Rohan Kumar',
            'Sick leave',
            'Aug 22 - 23',
            Color(0xFFB9D8FF),
          ),
          const Divider(height: 25),
          const _Request(
            'PN',
            'Priya Nair',
            'Work from home',
            'Aug 22',
            Color(0xFFD6C6FF),
          ),
        ],
      ),
    ),
  );
}

class _Request extends StatelessWidget {
  const _Request(this.initials, this.name, this.type, this.date, this.color);
  final String initials, name, type, date;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF3B3B50),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '$type  •  $date',
              style: const TextStyle(fontSize: 11, color: Color(0xFF858699)),
            ),
          ],
        ),
      ),
      const Icon(Icons.chevron_right_rounded, color: Color(0xFFABACB9)),
    ],
  );
}

class _Team extends StatelessWidget {
  const _Team();
  @override
  Widget build(BuildContext context) => _Panel(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Your team', 'Manage people  →'),
          const SizedBox(height: 18),
          const _Employee(
            'Neha Kapoor',
            'Product Designer',
            'Checked in 09:12',
            Color(0xFFFED2B6),
          ),
          const Divider(height: 24),
          const _Employee(
            'Arjun Mehta',
            'Software Engineer',
            'Checked in 09:04',
            Color(0xFFC6E5FF),
          ),
          const Divider(height: 24),
          const _Employee(
            'Sanya Verma',
            'Marketing Manager',
            'Working remotely',
            Color(0xFFE3D4FF),
          ),
        ],
      ),
    ),
  );
}

class _Employee extends StatelessWidget {
  const _Employee(this.name, this.role, this.status, this.color);
  final String name, role, status;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 19,
        backgroundColor: color,
        child: Text(
          name.split(' ').map((x) => x[0]).join(),
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF3B3B50),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              role,
              style: const TextStyle(fontSize: 11, color: Color(0xFF858699)),
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 7, color: Color(0xFF16A36A)),
              SizedBox(width: 4),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF16A36A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            status,
            style: const TextStyle(fontSize: 10, color: Color(0xFF858699)),
          ),
        ],
      ),
    ],
  );
}

class _Celebrations extends StatelessWidget {
  const _Celebrations();
  @override
  Widget build(BuildContext context) => _Panel(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Celebrations', 'View calendar  →'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉  Work anniversary',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Vikram is celebrating 3 years with us!',
                  style: TextStyle(fontSize: 12, color: Color(0xFF69667C)),
                ),
                SizedBox(height: 12),
                Text(
                  'Send wishes  →',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B5CE2),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFFFD8A8),
                child: Text(
                  'VK',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vikram Khanna',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Engineering • 3 years',
                    style: TextStyle(fontSize: 11, color: Color(0xFF858699)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
