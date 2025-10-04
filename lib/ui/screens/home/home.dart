import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paaieds/ui/screens/home/current_section.dart';
import 'package:paaieds/ui/screens/home/section.dart';

Color _darkenColor(Color color, double factor) {
  return HSLColor.fromColor(color)
      .withLightness(
        (HSLColor.fromColor(color).lightness - factor).clamp(0.0, 1.0),
      )
      .toColor();
}

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final data = <SectionData>[
    SectionData(
      color: Colors.blue,
      colorOscuro: _darkenColor(Colors.blue, 0.1),
      etapa: 1,
      seccion: 1,
      titulo: 'Preséntate',
    ),
    SectionData(
      color: Colors.orange,
      colorOscuro: _darkenColor(Colors.orange, 0.1),
      etapa: 1,
      seccion: 2,
      titulo: "Usa el tiempo presente",
    ),
    SectionData(
      color: Colors.green,
      colorOscuro: _darkenColor(Colors.green, 0.1),
      etapa: 1,
      seccion: 3,
      titulo: "Saluda y despídete",
    ),
    SectionData(
      color: Colors.purple,
      colorOscuro: _darkenColor(Colors.purple, 0.1),
      etapa: 1,
      seccion: 4,
      titulo: "Habla de comida",
    ),
  ];
  int iCurrentSection = 0;
  final heightFirstBox = 56.0;
  final heightSection = 764.0;
  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(scrollListener);
  }

  void scrollListener() {
    final currentScroll = scrollCtrl.position.pixels - heightFirstBox - 24.0;
    int index = (currentScroll / heightSection).floor();

    if (index < 0) index = 0;

    if (index != iCurrentSection) setState(() => iCurrentSection = index);
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBarInfo(
              asset: 'assets/angular-logo.png',
              value: '2',
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            AppBarInfo(
              isSvg: true,
              asset: 'assets/diamante.svg',
              value: '5',
              color: const Color.fromARGB(255, 89, 215, 240),
            ),
            AppBarInfo(
              isSvg: true,
              asset: 'assets/racha.svg',
              value: '5',
              color: const Color(0xFFEE5555),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView.separated(
            controller: scrollCtrl,
            itemBuilder: (_, i) => i == 0
                ? SizedBox(height: heightFirstBox)
                : Section(data: data[i - 1]),
            separatorBuilder: (_, i) => const SizedBox(height: 24.0),
            padding: const EdgeInsets.only(
              bottom: 24.0,
              left: 16.0,
              right: 16.0,
            ),
            itemCount: data.length + 1,
          ),
          CurrentSection(data: data[iCurrentSection]),
        ],
      ),
      backgroundColor: const Color(0xFF131F24),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2D3D41))),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 32),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book, size: 32),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield, size: 32),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dangerous, size: 32),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store, size: 32),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add, size: 32), label: ''),
          ],
        ),
      ),
    );
  }
}

class AppBarInfo extends StatelessWidget {
  final String asset;
  final String value;
  final Color color;
  final bool isSvg;

  const AppBarInfo({
    super.key,
    required this.asset,
    required this.value,
    required this.color,
    this.isSvg = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isSvg
            ? SvgPicture.asset(asset, width: 40, height: 40)
            : Image.asset(asset, width: 40, height: 40),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            fontSize: 16.0,
            color: color,
          ),
        ),
      ],
    );
  }
}
