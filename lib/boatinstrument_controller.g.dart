// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boatinstrument_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PageWidget _$PageWidgetFromJson(Map<String, dynamic> json) => _PageWidget(
      json['id'] as String,
      (json['percent'] as num).toDouble(),
    );

Map<String, dynamic> _$PageWidgetToJson(_PageWidget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'percent': instance.percent,
    };

_Page _$PageFromJson(Map<String, dynamic> json) => _Page(
      json['name'] as String,
      (json['rows'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => _PageWidget.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$PageToJson(_Page instance) => <String, dynamic>{
      'name': instance.name,
      'rows': instance.rows,
    };

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      valueSmoothing: json['valueSmoothing'] as int? ?? 0,
      signalkServer:
          json['signalkServer'] as String? ?? 'openplotter.local:3000',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => _Page.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      widgetSettings:
          json['widgetSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'valueSmoothing': instance.valueSmoothing,
      'signalkServer': instance.signalkServer,
      'pages': instance.pages,
      'widgetSettings': instance.widgetSettings,
    };
