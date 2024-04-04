import 'package:flutter_test/flutter_test.dart';
import 'package:nav/signalk.dart';

void main() {
  test('Angle averaging', ()
  {
    expect(rad2Deg(averageAngle(deg2Rad( 10), deg2Rad(350))), 360);
    expect(rad2Deg(averageAngle(deg2Rad(350), deg2Rad( 10))), 360);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(135))),  90);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad( 45))),  90);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad(225))), 180);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(135))), 180);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(315))), 270);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad(225))), 270);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad( 45))), 360);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(315))), 360);
  });

  test('Angle smoothing', ()
  {
    // 1 is no smoothing, so these should be the same as the average.
    expect(rad2Deg(smoothAngle(deg2Rad( 10), deg2Rad(350), 1)), 360);
    expect(rad2Deg(smoothAngle(deg2Rad(350), deg2Rad( 10), 1)), 360);
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(135), 1)),  90);
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad( 45), 1)),  90);
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad(225), 1)), 180);
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(135), 1)), 180);
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(315), 1)), 270);
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad(225), 1)), 270);
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad( 45), 1)), 360);
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(315), 1)), 360);

    // These should be more towards the first value.
    expect(rad2Deg(smoothAngle(deg2Rad( 10), deg2Rad(350), 2)),   5); // 360
    expect(rad2Deg(smoothAngle(deg2Rad(350), deg2Rad( 10), 2)), 355); // 360
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(135), 2)),  68); //  90
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad( 45), 2)), 113); //  90
    expect(rad2Deg(smoothAngle(deg2Rad(135), deg2Rad(225), 2)), 158); // 180
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(135), 2)), 203); // 180
    expect(rad2Deg(smoothAngle(deg2Rad(225), deg2Rad(315), 2)), 248); // 270
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad(225), 2)), 293); // 270
    expect(rad2Deg(smoothAngle(deg2Rad(315), deg2Rad( 45), 2)), 338); // 360
    expect(rad2Deg(smoothAngle(deg2Rad( 45), deg2Rad(315), 2)),  22); // 360
  });
}
