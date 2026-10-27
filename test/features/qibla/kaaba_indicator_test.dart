import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salah/features/qibla/presentation/widgets/kaaba_marker.dart';
import 'package:salah/features/qibla/presentation/widgets/qibla_direction_indicator.dart';

void main() {
  testWidgets('Kaaba marker follows all four relative compass directions', (
    tester,
  ) async {
    for (final bearing in [0.0, 90.0, 180.0, 270.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: 284,
              child: QiblaDirectionIndicator(
                bearing: bearing,
                dialSize: 284,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final center = tester.getCenter(find.byType(QiblaDirectionIndicator));
      final marker = tester.getCenter(find.byType(KaabaMarker));
      final delta = marker - center;
      if (bearing == 0) {
        expect(delta.dy, lessThan(-60));
        expect(delta.dx.abs(), lessThan(1));
      }
      if (bearing == 90) {
        expect(delta.dx, greaterThan(60));
        expect(delta.dy.abs(), lessThan(1));
      }
      if (bearing == 180) {
        expect(delta.dy, greaterThan(60));
        expect(delta.dx.abs(), lessThan(1));
      }
      if (bearing == 270) {
        expect(delta.dx, lessThan(-60));
        expect(delta.dy.abs(), lessThan(1));
      }
    }
  });
  testWidgets(
    'North crossing keeps the Kaaba close to north throughout animation',
    (tester) async {
      Widget app(double bearing) => MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 284,
            child: QiblaDirectionIndicator(
              bearing: bearing,
              dialSize: 284,
              color: Colors.green,
            ),
          ),
        ),
      );
      await tester.pumpWidget(app(359));
      await tester.pumpAndSettle();
      await tester.pumpWidget(app(1));
      await tester.pump(const Duration(milliseconds: 90));
      expect(
        (tester.getCenter(find.byType(KaabaMarker)) -
                tester.getCenter(find.byType(QiblaDirectionIndicator)))
            .dy,
        lessThan(-60),
      );
      await tester.pumpAndSettle();
    },
  );
}
