import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends StatelessWidget {
  final ColorScheme? light;
  final ColorScheme? dark;
  const MyApp({super.key, this.light, this.dark});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroNext',
      theme: ThemeData.from(colorScheme: light ?? const ColorScheme.light())
          .copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
          ),
      darkTheme: ThemeData.from(colorScheme: dark ?? const ColorScheme.dark())
          .copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
          ),
      themeMode: ThemeMode.system,
      home: const MetroDynamicPage(),
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

class MetroDynamicPage extends StatelessWidget {
  const MetroDynamicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stations = [
      StationData("南港展覽館", "Taipei Nangang Exhibition Center", "BR24"),
      StationData("南港軟體園區", "Nangang Software Park", "BR23"),
      StationData("東湖", "Donghu", "BR22"),
      StationData("葫洲", "Huzhou", "BR21"),
      StationData("大湖公園", "Dahu Park", "BR20"),
      StationData("內湖", "Neihu", "BR19"),
      StationData("文德", "Wende", "BR18"),
      StationData("港墘", "Gangqian", "BR17"),
      StationData("西湖", "Xihu", "BR16"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("BR 文湖線 動態資訊")),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          return StationRow(
            station: stations[index],
            upCongest: index % 3,     // 假資料：0綠 1黃 2紅
            downCongest: (index + 1) % 3,
            trainsUp: index == 3 ? ["南港展覽館"] : [],
            trainsDown: index == 5 ? ["動物園", "動物園"] : [],
            isSelected: index == 4,
          );
        },
      ),
    );
  }
}

class StationData {
  final String name;
  final String eng;
  final String code;

  StationData(this.name, this.eng, this.code);
}

class StationRow extends StatelessWidget {
  final StationData station;
  final int upCongest;
  final int downCongest;
  final bool isSelected;
  final List<String> trainsUp;
  final List<String> trainsDown;

  const StationRow({
    super.key,
    required this.station,
    required this.upCongest,
    required this.downCongest,
    required this.trainsUp,
    required this.trainsDown,
    required this.isSelected,
  });

  Color _level(int v) {
    switch (v) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95, // 等距高度（重點）
      child: Row(
        children: [
          // 左側車站名稱
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(station.eng,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      )),
                  Text(station.code,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      )),
                ],
              ),
            ),
          ),

          // 中間動態線路圖
          SizedBox(
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 上行線（左）
                Positioned(
                  left: 20,
                  child: Container(
                    width: 6,
                    height: 95,
                    color: _level(upCongest),
                  ),
                ),
                // 下行線（右）
                Positioned(
                  right: 20,
                  child: Container(
                    width: 6,
                    height: 95,
                    color: _level(downCongest),
                  ),
                ),

                // 中間站點
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: 3,
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 右側列車 Icon + 目的地
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 上行列車
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: trainsUp.map((dest) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.train, size: 20),
                          const SizedBox(width: 4),
                          Text(dest),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(width: 18),

                  // 下行列車
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: trainsDown.map((dest) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.train, size: 20),
                          const SizedBox(width: 4),
                          Text(dest),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
