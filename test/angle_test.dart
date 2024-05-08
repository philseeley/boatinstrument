import 'package:flutter_test/flutter_test.dart';
import 'package:boatinstrument/signalk.dart';

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

    expect(rad2Deg(averageAngle(deg2Rad(- 10), deg2Rad(  10), relative: true)), - 0);
    expect(rad2Deg(averageAngle(deg2Rad(- 10), deg2Rad(-350), relative: true)), - 0);
    expect(rad2Deg(averageAngle(deg2Rad(-350), deg2Rad(- 10), relative: true)), - 0);
    expect(rad2Deg(averageAngle(deg2Rad(- 45), deg2Rad(-135), relative: true)), - 90);
    expect(rad2Deg(averageAngle(deg2Rad(-135), deg2Rad(- 45), relative: true)), - 90);
    expect(rad2Deg(averageAngle(deg2Rad(-135), deg2Rad(-225), relative: true)),  180);
    expect(rad2Deg(averageAngle(deg2Rad(-225), deg2Rad(-135), relative: true)),  180);
    expect(rad2Deg(averageAngle(deg2Rad(-315), deg2Rad(- 45), relative: true)), -  0);
    expect(rad2Deg(averageAngle(deg2Rad(- 45), deg2Rad(-315), relative: true)), -  0);
  });

  test('Angle smoothing', ()
  {
    expect(rad2Deg(averageAngle(deg2Rad( 10), deg2Rad(350), smooth: 10)),   1);
    expect(rad2Deg(averageAngle(deg2Rad(350), deg2Rad( 10), smooth: 10)), 359);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(135), smooth: 10)),  85);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad( 45), smooth: 10)),  95);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad(225), smooth: 10)), 175);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(135), smooth: 10)), 185);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(315), smooth: 10)), 265);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad(225), smooth: 10)), 275);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad( 45), smooth: 10)), 355);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(315), smooth: 10)),   5);

    expect(rad2Deg(averageAngle(deg2Rad(  10), deg2Rad(- 10), smooth: 10, relative: true)),    1);
    expect(rad2Deg(averageAngle(deg2Rad(- 10), deg2Rad(  10), smooth: 10, relative: true)), -  1);
    expect(rad2Deg(averageAngle(deg2Rad(  45), deg2Rad( 135), smooth: 10, relative: true)),   85);
    expect(rad2Deg(averageAngle(deg2Rad( 135), deg2Rad(  45), smooth: 10, relative: true)),   95);
    expect(rad2Deg(averageAngle(deg2Rad(- 45), deg2Rad(-135), smooth: 10, relative: true)), - 85);
    expect(rad2Deg(averageAngle(deg2Rad(-135), deg2Rad(- 45), smooth: 10, relative: true)), - 95);
  });
}
