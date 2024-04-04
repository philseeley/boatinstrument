import 'package:flutter_test/flutter_test.dart';
import 'package:nav/signalk.dart';

void main() {
  test('Angle averaging', ()
  {
    expect(rad2Deg(averageAngle(deg2Rad( 10), deg2Rad(350))),   0);
    expect(rad2Deg(averageAngle(deg2Rad(350), deg2Rad( 10))),   0);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(135))),  90);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad( 45))),  90);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad(225))), 180);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(135))), 180);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(315))), 270);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad(225))), 270);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad( 45))),   0);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(315))),   0);
  });

  test('Angle smoothing', ()
  {
    // 1 is no smoothing, so these should be the same as the average.
    expect(rad2Deg(smoothAngle(deg2Rad( 10), deg2Rad(350), 1)),   0);
    expect(rad2Deg(smoothAngle(deg2Rad(350), deg2Rad( 10), 1)),   0);
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(135), 1)),  90);
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad( 45), 1)),  90);
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad(225), 1)), 180);
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(135), 1)), 180);
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(315), 1)), 270);
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad(225), 1)), 270);
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad( 45), 1)),   0);
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(315), 1)),   0);

    // These should be more towards the first value.
    expect(rad2Deg(smoothAngle(deg2Rad( 10), deg2Rad(350), 2)),   5); //   0
    expect(rad2Deg(smoothAngle(deg2Rad(350), deg2Rad( 10), 2)), 355); //   0
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(135), 2)),  68); //  90
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad( 45), 2)), 113); //  90
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad(225), 2)), 158); // 180
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(135), 2)), 203); // 180
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(315), 2)), 248); // 270
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad(225), 2)), 293); // 270
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad( 45), 2)), 338); //   0
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(315), 2)),  22); //   0
  });
}
