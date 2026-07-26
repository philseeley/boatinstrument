import 'package:flutter_test/flutter_test.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

void main() {
  test('Double Averaging', ()
  {
    var avgDouble = AverageDouble();
    [
       10.0,
       20.0,
       30.0
    ].forEach(avgDouble.add);
    expect(avgDouble.average, 20.0);

    avgDouble = AverageDouble();
    [
      -30.0,
      -20.0,
      -10.0,
    ].forEach(avgDouble.add);
    expect(avgDouble.average, -20.0);
    avgDouble = AverageDouble();
    [
      -30.0,
      -20.0,
      -10.0,
        0.0,
       10.0,
       20.0,
       30.0
    ].forEach(avgDouble.add);
    expect(avgDouble.average, 0.0);
  });

  test('Angle Averaging', ()
  {
    var avgAngle = AverageAngle(relative: true);
    [
      deg2Rad(-30),
      deg2Rad(-20),
      deg2Rad(-10),
      deg2Rad(  0),
      deg2Rad( 10),
      deg2Rad( 20),
      deg2Rad( 30)
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 0);

    avgAngle = AverageAngle(relative: true);
    [
      deg2Rad(-30),
      deg2Rad(-20),
      deg2Rad(-10),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), -20);

    avgAngle = AverageAngle();
    [
      deg2Rad( 30),
      deg2Rad( 20),
      deg2Rad( 10),
      deg2Rad( 15),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 19);

    avgAngle = AverageAngle();
    [
      deg2Rad(330),
      deg2Rad( 20),
      deg2Rad( 10),
      deg2Rad( 15),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 4);

    avgAngle = AverageAngle();
    [
      deg2Rad(-30),
      deg2Rad( 20),
      deg2Rad( 10),
      deg2Rad( 15),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 4);

    avgAngle = AverageAngle();
    [
      deg2Rad(330),
      deg2Rad( 90),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 30);

    avgAngle = AverageAngle();
    [
      deg2Rad(91),
      deg2Rad(269),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 180);

    avgAngle = AverageAngle();
    [
      deg2Rad(89),
      deg2Rad(271),
    ].forEach(avgAngle.add);
    expect(rad2Deg(avgAngle.average), 0);
  });
}
