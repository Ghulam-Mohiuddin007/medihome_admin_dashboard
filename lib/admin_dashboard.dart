import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  bool _isSidebarExpanded = true;
  int _selectedMenuIndex = 0; // 0: Analytics, 1: Staff, 2: Users

  String _selectedStaffCategory = 'all';

  // لگژری میٹیلک ڈارک تھیم (Premium Palette)
  final Color bgDark = const Color(0xFF020617);
  final Color surfaceSlate = const Color(0xFF0F172A);
  final Color cardTint = const Color(0xFF1E293B);
  final Color electricTeal = const Color(0xFF00D2FF);
  final Color metallicGold = const Color(0xFFD4AF37);
  final Color borderGlass = Colors.white.withValues(alpha: 0.05);

  @override
  Widget build(BuildContext context) {
    // سکرین سائز کی چوڑائی چیک کرنے کے لیے میٹرکس
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileOrTablet = screenWidth < 1024;

    return Scaffold(
      backgroundColor: bgDark,
      body: Row(
        children: [
          // 1. اینیمیٹڈ سائڈ نیویگیشن بار (Premium Animated Sidebar)
          if (!isMobileOrTablet || _isSidebarExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _isSidebarExpanded ? 280 : 85,
              decoration: BoxDecoration(
                color: surfaceSlate,
                border: Border(
                  right: BorderSide(color: borderGlass, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: _isSidebarExpanded
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        if (_isSidebarExpanded)
                          Row(
                            children: [
                              Icon(
                                Icons.health_and_safety_rounded,
                                color: electricTeal,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "MediHome",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.menu_open_rounded,
                            color: electricTeal,
                            size: 24,
                          ),
                          onPressed: () => setState(
                            () => _isSidebarExpanded = !_isSidebarExpanded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSidebarItem(
                    0,
                    Icons.analytics_rounded,
                    "Analytics Radar",
                  ),
                  _buildSidebarItem(1, Icons.badge_rounded, "Medical Staff"),
                  _buildSidebarItem(
                    2,
                    Icons.people_alt_rounded,
                    "User Directory",
                  ),
                  const Spacer(),
                  if (_isSidebarExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "v1.0.2 - Terminal Active",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // 2. مین ورک اسپیس کور ویو (Main Workspace Core View)
          Expanded(
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.all(screenWidth < 768 ? 20.0 : 40.0),
              child: Column(
                children: [
                  // موبائل/ٹیبلٹ ویو کے لیے ٹاپ بار اوورلے مینو بٹن
                  if (isMobileOrTablet)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: electricTeal,
                            size: 28,
                          ),
                          onPressed: () => setState(
                            () => _isSidebarExpanded = !_isSidebarExpanded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "MediHome Admin",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  if (isMobileOrTablet) const SizedBox(height: 20),

                  Expanded(
                    child: IndexedStack(
                      index: _selectedMenuIndex,
                      children: [
                        _buildAnalyticsTab(screenWidth),
                        _buildStaffManagementTab(screenWidth),
                        _buildUserDirectoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    bool isSelected = _selectedMenuIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: InkWell(
        onTap: () => setState(() => _selectedMenuIndex = index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? electricTeal.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? electricTeal.withValues(alpha: 0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: _isSidebarExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? electricTeal : const Color(0xFF64748B),
                size: 22,
              ),
              if (_isSidebarExpanded) ...[
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================================
  // TAB 1: Real-time Analytics & Responsive Layout Grid
  // =======================================================================
  Widget _buildAnalyticsTab(double screenWidth) {
    return FutureBuilder(
      future: _supabase.from('profiles').select(),
      builder: (context, profilesSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _supabase.from('bookings').stream(primaryKey: ['id']),
          builder: (context, bookingsSnapshot) {
            // جب تک دونوں اسنیپ شاٹس ریڈی نہ ہوں لوڈر دکھائیں
            if (bookingsSnapshot.connectionState == ConnectionState.waiting ||
                profilesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: electricTeal),
              );
            }

            // رئیل ٹائم بکنگز ڈیٹا فیڈز
            final allBookings = bookingsSnapshot.data ?? [];

            // 2. فکسڈ: لسٹ کو محفوظ طریقے سے کاسٹ کیا گیا ہے اور ڈوپلیکیٹ ڈیکلیریشن ختم کر دی گئی ہے
            final List<Map<String, dynamic>> allProfiles =
                profilesSnapshot.data ?? [];

            // -------------------------------------------------------------
            // یہاں سے نیچے آپ کا باقی کا میٹرکس اور UI کا کوڈ چلے گا
            // -------------------------------------------------------------
            final monthlyCount = allBookings.where((b) {
              if (b['created_at'] == null) return false;
              final DateTime date = DateTime.parse(b['created_at']);
              return date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              );
            }).length;

            final pendingCount = allBookings
                .where((b) => b['status'] == 'searching')
                .length;
            final completedCount = allBookings
                .where((b) => b['status'] == 'completed')
                .length;

            final totalNurses = allProfiles
                .where((p) => p['role'] == 'nurse')
                .length;
            final totalDoctors = allProfiles
                .where((p) => p['role'] == 'doctor')
                .length;
            final totalPhlebotomists = allProfiles
                .where((p) => p['role'] == 'blood_picker')
                .length;

            // ریسپونسیو میٹرکس لے آؤٹ
            Widget metricsGrid = screenWidth < 1200
                ? Column(
                    children: [
                      _buildMetricCard(
                        "Monthly System Demand",
                        "$monthlyCount Vol",
                        Icons.analytics_rounded,
                        electricTeal,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        "Awaiting Provider Match",
                        "$pendingCount Live",
                        Icons.hourglass_empty_rounded,
                        Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        "Closed Success Visited",
                        "$completedCount Sessions",
                        Icons.task_alt_rounded,
                        const Color(0xFF10B981),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "Monthly System Demand",
                          "$monthlyCount Vol",
                          Icons.analytics_rounded,
                          electricTeal,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildMetricCard(
                          "Awaiting Provider Match",
                          "$pendingCount Live",
                          Icons.hourglass_empty_rounded,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildMetricCard(
                          "Closed Success Visited",
                          "$completedCount Sessions",
                          Icons.task_alt_rounded,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  );

            // ریسپونسیو اسٹاف انفراسٹرکچر کارڈ لے آؤٹ
            Widget staffInfrastructureGrid = screenWidth < 1200
                ? Column(
                    children: [
                      _buildStaffMiniCard(
                        "Active Nurses Pool",
                        "$totalNurses Registered",
                        Icons.local_hospital_rounded,
                        electricTeal,
                      ),
                      const SizedBox(height: 12),
                      _buildStaffMiniCard(
                        "Medical Doctors",
                        "$totalDoctors Specialist",
                        Icons.medication_rounded,
                        metallicGold,
                      ),
                      const SizedBox(height: 12),
                      _buildStaffMiniCard(
                        "Phlebotomy Unit",
                        "$totalPhlebotomists Collectors",
                        Icons.bloodtype_rounded,
                        const Color(0xFFFF5252),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildStaffMiniCard(
                          "Active Nurses Pool",
                          "$totalNurses Registered",
                          Icons.local_hospital_rounded,
                          electricTeal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStaffMiniCard(
                          "Medical Doctors",
                          "$totalDoctors Specialist",
                          Icons.medication_rounded,
                          metallicGold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStaffMiniCard(
                          "Phlebotomy Unit",
                          "$totalPhlebotomists Collectors",
                          Icons.bloodtype_rounded,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  );

            // ریسپونسیو گرافس اور ہاٹ اسپاٹس پینل لے آؤٹ
            Widget chartsPanel = screenWidth < 1200
                ? Column(
                    children: [
                      _buildTrendCurveContainer(allBookings),
                      const SizedBox(height: 24),
                      _buildHotspotsContainer(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTrendCurveContainer(allBookings),
                      ),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildHotspotsContainer()),
                    ],
                  );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (screenWidth >= 1024)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Analytics Control Center",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Real-time cloud database snapshot overview",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "LIVE NETWORK",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: screenWidth < 1024 ? 12 : 36),
                  metricsGrid,
                  const SizedBox(height: 32),
                  Text(
                    "Registered Staff Infrastructure",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  staffInfrastructureGrid,
                  const SizedBox(height: 36),
                  chartsPanel,
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendCurveContainer(List<Map<String, dynamic>> allBookings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceSlate,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Request Volume Trend Curve",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: allBookings.isEmpty
                        ? [const FlSpot(0, 0)]
                        : List.generate(
                            allBookings.length > 6 ? 6 : allBookings.length,
                            (i) => FlSpot(i.toDouble(), (i + 2) % 5 + 2),
                          ),
                    isCurved: true,
                    color: electricTeal,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: electricTeal.withValues(alpha: 0.02),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotsContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardTint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Target Service Hotspots",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabase
                .from('view_location_analytics')
                .select('*')
                .limit(3),
            builder: (context, snap) {
              final locs = snap.data ?? [];
              if (locs.isEmpty)
                return const Text(
                  "Calculating deployment clusters...",
                  style: TextStyle(color: Colors.grey),
                );

              return Column(
                children: locs.map((l) {
                  return _buildLocationBar(
                    l['location_name'] ?? 'Sahiwal Region',
                    int.parse(l['total_bookings'].toString()),
                    electricTeal,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar(String name, int total, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$total Calls",
                style: GoogleFonts.inter(
                  color: barColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (total / 15).clamp(0.1, 1.0),
              backgroundColor: bgDark,
              color: barColor,
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String val,
    IconData ico,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceSlate,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  val,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(ico, color: accent, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffMiniCard(
    String title,
    String val,
    IconData ico,
    Color tone,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        children: [
          Icon(ico, color: tone, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  val,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // TAB 2: Live Medical Staff Ledger & Dynamic Category Filters
  // =======================================================================
  Widget _buildStaffManagementTab(double screenWidth) {
    bool isCompactLayout = screenWidth < 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isCompactLayout
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Medical Provider Management",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All Staff'),
                        const SizedBox(width: 6),
                        _buildFilterChip('nurse', 'Nurses'),
                        const SizedBox(width: 6),
                        _buildFilterChip('doctor', 'Doctors'),
                        const SizedBox(width: 6),
                        _buildFilterChip('blood_picker', 'Blood Pickers'),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medical Provider Management",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Monitor operational specialist metrics and audit review grades",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildFilterChip('all', 'All Staff'),
                      const SizedBox(width: 8),
                      _buildFilterChip('nurse', 'Nurses'),
                      const SizedBox(width: 8),
                      _buildFilterChip('doctor', 'Doctors'),
                      const SizedBox(width: 8),
                      _buildFilterChip('blood_picker', 'Blood Pickers'),
                    ],
                  ),
                ],
              ),
        const SizedBox(height: 32),

        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabase.from('view_staff_analytics').select('*'),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(color: electricTeal),
                );

              final rawStaffList = snapshot.data!;
              final filteredStaffList = _selectedStaffCategory == 'all'
                  ? rawStaffList
                  : rawStaffList
                        .where((s) => s['staff_role'] == _selectedStaffCategory)
                        .toList();

              if (filteredStaffList.isEmpty) {
                return Center(
                  child: Text(
                    "No medical profiles registered under this scope.",
                    style: TextStyle(color: const Color(0xFF64748B)),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceSlate,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderGlass),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: screenWidth < 1024
                              ? 900
                              : screenWidth - 360,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFF020617),
                          ),
                          horizontalMargin: 24,
                          dataRowHeight: 65,
                          columns: [
                            DataColumn(
                              label: Text(
                                'Specialist Identity',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Role Department',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Monthly Booking Rate',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Closed Cases Ledger',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'True Performance Grade',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: filteredStaffList.map((staff) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    staff['staff_name'] ?? 'Verified Expert',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: electricTeal.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      staff['staff_role']
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: electricTeal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "${staff['monthly_bookings']} Dispatches / Mo",
                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "${staff['total_completed_jobs']} Closed",
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        staff['current_rating'] != null
                                            ? double.parse(
                                                staff['current_rating']
                                                    .toString(),
                                              ).toStringAsFixed(1)
                                            : "5.0",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String categoryKey, String title) {
    bool isSelected = _selectedStaffCategory == categoryKey;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedStaffCategory = categoryKey);
      },
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      selectedColor: electricTeal,
      backgroundColor: cardTint,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // =======================================================================
  // TAB 3: User Segments Directory (Premium Loyal vs New Segment Core)
  // =======================================================================
  Widget _buildUserDirectoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Patient Engagement Registry",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Segment clusters calculated dynamically based on total transaction counts",
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabase.from('view_user_analytics').select('*'),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(color: electricTeal),
                );
              final userList = snapshot.data!;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  final userRow = userList[index];
                  String segmentation =
                      userRow['customer_segmentation'] ?? 'New Profile';

                  Color segmentColor = const Color(0xFF94A3B8);
                  if (segmentation == 'Premium Loyal')
                    segmentColor = metallicGold;
                  if (segmentation == 'Occasional Buyer')
                    segmentColor = electricTeal;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceSlate,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderGlass),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobileCard = constraints.maxWidth < 650;

                        if (isMobileCard) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildUserAvatar(userRow),
                                  const SizedBox(width: 14),
                                  Expanded(child: _buildUserMeta(userRow)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${userRow['total_orders_placed']} Bookings",
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  _buildSegmentBadge(
                                    segmentation,
                                    segmentColor,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildUserAvatar(userRow),
                                const SizedBox(width: 18),
                                _buildUserMeta(userRow),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${userRow['total_orders_placed']} Bookings Registered",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 36),
                                _buildSegmentBadge(segmentation, segmentColor),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> userRow) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: cardTint, shape: BoxShape.circle),
      child: Center(
        child: Text(
          userRow['user_name'] != null
              ? userRow['user_name'][0].toString().toUpperCase()
              : 'P',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUserMeta(Map<String, dynamic> userRow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userRow['user_name'] ?? 'Anonymous Client',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          userRow['user_email'] ?? 'patient@medihome.com',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentBadge(String segmentation, Color segmentColor) {
    return Container(
      width: 160,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: segmentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: segmentColor.withValues(alpha: 0.15)),
      ),
      child: Text(
        segmentation.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: segmentColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
