import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/utils/responsive_helper.dart';

void main() {
  testWidgets('viewSafeBottom inclut le viewPadding système', (tester) async {
    late double padding;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          viewPadding: EdgeInsets.only(bottom: 34),
          padding: EdgeInsets.only(bottom: 34),
        ),
        child: Builder(
          builder: (context) {
            padding = ResponsiveHelper.viewSafeBottom(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(padding, 50);
  });
}
