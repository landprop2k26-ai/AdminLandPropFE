import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'widgets/stat_card.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1100) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildLeftColumn()),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: _buildRightColumn()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLeftColumn(),
                      const SizedBox(height: 32),
                      _buildRightColumn(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('23 May 2024', style: TextStyle(color: Colors.grey)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add Worker +'),
                  ),
                ],
              ),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text('23 May 2024', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add Worker +'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        double aspectRatio = 1.8;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
          aspectRatio = 3.0;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
          aspectRatio = 2.0;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4;
          aspectRatio = 1.4;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: const [
            StatCard(
              title: 'Active Workers',
              value: '24',
              trend: '18 on job today (+12% from last month)',
            ),
            StatCard(
              title: 'Revenue Today',
              value: '₹18,400',
              trend: '12 jobs completed (+32% vs yesterday)',
            ),
            StatCard(
              title: 'Weekly Income',
              value: '₹96,200',
              trend: '67 jobs this week (-4% vs last week)',
              isPositive: false,
            ),
            StatCard(
              title: 'Active Listings',
              value: '12',
              trend: '8 rented - 4 sold (2 new this week)',
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildWorkerOverview(),
        const SizedBox(height: 32),
        _buildRevenueChart(),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildPropertyListings(),
        const SizedBox(height: 32),
        _buildRecentBookings(),
      ],
    );
  }

  Widget _buildWorkerOverview() {
    return _buildCard(
      title: 'Worker Overview',
      actionText: 'View all \u2192',
      child: Column(
        children: [
          _workerTile('Ravi Kumar', 'Electrician \u2022 Plumber', '₹11,200', Colors.green),
          _workerTile('Suresh Kiran', 'Carpenter', '₹7,800', Colors.blue),
          _workerTile('Mahesh Reddy', 'Painter \u2022 Plumber', '₹5,500', Colors.orange),
          _workerTile('Arun Prasad', 'AC Repair', '₹2,300', Colors.purple),
          _workerTile('Vijay Naidu', 'Electrician \u2022 Carpenter', '₹7,400', Colors.indigo),
        ],
      ),
    );
  }

  Widget _workerTile(String name, String role, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Text(name.substring(0, 1), style: TextStyle(color: color, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(role, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('this month', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return _buildCard(
      title: 'Revenue \u2014 Last 7 Days',
      actionText: 'Full report \u2192',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              _barGroup(0, 10),
              _barGroup(1, 14),
              _barGroup(2, 9),
              _barGroup(3, 17),
              _barGroup(4, 15),
              _barGroup(5, 20),
              _barGroup(6, 4),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.accent,
          width: 25,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPropertyListings() {
    return _buildCard(
      title: 'Property Listings',
      actionText: 'Post new +',
      child: Column(
        children: [
          _propertyTile('3BHK Flat, Banjara Hills', 'Hyderabad \u2022 1,600 sqft', 'Rent', '₹20,000/mo', Colors.green),
          _propertyTile('Open Plot, Kompally', 'Hyderabad \u2022 200 sq yd', 'Sold', '₹42L', Colors.blue),
          _propertyTile('Office Space, Madhapur', 'Hyderabad \u2022 500 sqft', 'Rent', '₹40,000/mo', Colors.teal),
          _propertyTile('Independent House, Miyapur', 'Hyderabad \u2022 1,400 sqft', 'Sold', '₹78L', Colors.red),
        ],
      ),
    );
  }

  Widget _propertyTile(String title, String desc, String status, String price, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.home, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(status, style: TextStyle(color: color, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    return _buildCard(
      title: 'Recent Bookings',
      actionText: 'View all \u2192',
      child: Column(
        children: [
          _bookingTile('Sreekanth B', 'Electrical repair \u2022 Ravi Kumar', 'Closed', '₹1,500', Colors.green),
          _bookingTile('Divya M', 'Carpentry \u2022 Suresh Kiran', 'In Progress', '₹3,400', Colors.orange),
          _bookingTile('Naveen G', 'Painting \u2022 Mahesh Reddy', 'Closed', '₹5,200', Colors.green),
          _bookingTile('Priya S', 'AC Repair \u2022 Arun Prasad', 'Pending', '₹1,120', Colors.blue),
          _bookingTile('Ramesh K', 'Electrical \u2022 Vijay Naidu', 'Closed', '₹910', Colors.green),
        ],
      ),
    );
  }

  Widget _bookingTile(String client, String service, String status, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(service, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(color: color, fontSize: 10)),
          ),
          const SizedBox(width: 16),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String actionText, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: Text(actionText, style: const TextStyle(color: AppColors.accent))),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
