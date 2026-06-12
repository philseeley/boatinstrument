# Alerts/Zones

Alerts can be set using SignalK Zones. This is a two step process, first define the desired alerts and second apply them to the server.

By default, when an Alert is received an audio tone is played. This can be overridden for each Alert level through the Audio Settings ![enable](assets/icons/__THEME__/notifications.png).

## Defining Alerts

For each value, e.g. True Wind Speed, you can define multiple thresholds, e.g. a Warning at 15kts, an Alarm at 20kts and then an Emergency at 25kts.

For decreasing values, e.g. Depth Below Keel, the alerts are triggered when the value falls below the defined thresholds, e.g. Warning at 10m and then an Alarm at 5m.

## Setting Alerts

Once you have defined the desired alerts on the Settings Page, you can then enable ![enable](assets/icons/__THEME__/check_circle.png) and disable ![disable](assets/icons/__THEME__/cancel.png) them. Once enabled, the alerts stay in effect through SignalK server restarts.