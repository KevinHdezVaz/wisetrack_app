import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/BalanceScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/dashboard/DataVisualizationScreen.dart';

// Importa los widgets de contenido y los modelos que hemos creado/usado
// import 'balance_content.dart';
// import 'data_visualization_content.dart';
// import 'app_colors.dart';

class CombinedDashboardScreen extends StatefulWidget {
  const CombinedDashboardScreen({Key? key}) : super(key: key);

  @override
  _CombinedDashboardScreenState createState() =>
      _CombinedDashboardScreenState();
}

class _CombinedDashboardScreenState extends State<CombinedDashboardScreen> {
  // 0 para "Balance de Hoy", 1 para "Dashboard"
  int _selectedTabIndex = 0;

  final List<String> _titles = ['Balance de Hoy', 'Dashboard'];
  final List<Widget> _tabContents = [
    const BalanceScreen(),
    const DataVisualizationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _buildBackButton(context),
        // El título cambia según la pestaña seleccionada
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_selectedTabIndex],
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text('San Isidro - Lun 12 may.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        actions: [
          if (_selectedTabIndex ==
              0) // Muestra el botón de refresh solo en "Balance"
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black54),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            // IndexedStack muestra solo el widget correspondiente al índice actual
            // pero mantiene el estado de los otros widgets en memoria.
            child: IndexedStack(
              index: _selectedTabIndex,
              children: _tabContents,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildCustomTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTabButton(0, 'Balance de Hoy'),
            _buildTabButton(1, 'Dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.black54,
          elevation: isSelected ? 2 : 0,
          shadowColor: isSelected
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- Clases y widgets de soporte que ya tenías ---
// (Debes tenerlas importadas o definidas en los mismos archivos)
class AppColors {
  static const Color primary = Color(0xFF00636A);
}

class MetricCard extends StatelessWidget {
  /*...*/ const MetricCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}

class ChartCard extends StatelessWidget {
  /*...*/ const ChartCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}

class LegendItem {
  const LegendItem(
      {required String text, required String value, required Color color});
}

class BarChartDataModel {
  const BarChartDataModel(
      {required String label, required double value, required Color color});
}
