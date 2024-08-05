import 'package:flutter_test/flutter_test.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

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
    expect(rad2Deg(averageAngle(deg2Rad( 10), deg2Rad(350), smooth: 10)),   8);
    expect(rad2Deg(averageAngle(deg2Rad(350), deg2Rad( 10), smooth: 10)), 352);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(135), smooth: 10)),  51);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad( 45), smooth: 10)), 129);
    expect(rad2Deg(averageAngle(deg2Rad(135), deg2Rad(225), smooth: 10)), 141);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(135), smooth: 10)), 219);
    expect(rad2Deg(averageAngle(deg2Rad(225), deg2Rad(315), smooth: 10)), 231);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad(225), smooth: 10)), 309);
    expect(rad2Deg(averageAngle(deg2Rad(315), deg2Rad( 45), smooth: 10)), 321);
    expect(rad2Deg(averageAngle(deg2Rad( 45), deg2Rad(315), smooth: 10)),  39);

    expect(rad2Deg(averageAngle(deg2Rad(  10), deg2Rad(- 10), smooth: 10, relative: true)),    8);
    expect(rad2Deg(averageAngle(deg2Rad(- 10), deg2Rad(  10), smooth: 10, relative: true)), -  8);
    expect(rad2Deg(averageAngle(deg2Rad(  45), deg2Rad( 135), smooth: 10, relative: true)),   51);
    expect(rad2Deg(averageAngle(deg2Rad( 135), deg2Rad(  45), smooth: 10, relative: true)),  129);
    expect(rad2Deg(averageAngle(deg2Rad(- 45), deg2Rad(-135), smooth: 10, relative: true)), - 51);
    expect(rad2Deg(averageAngle(deg2Rad(-135), deg2Rad(- 45), smooth: 10, relative: true)), -129);
  });
}
