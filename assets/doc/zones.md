# Alerts/Zones

Alerts can be set using SignalK Zones. This is a two step process, first define the desired alerts and second apply them to the server.

By default, when an Alert is received an audio tone is played. This can be overridden for each Alert level through the Audio Settings ![enable](assets/icons/__THEME__/notifications.png).

**Note:** values like Battery Current may need to have negative thresholds set, e.g. to alarm if a battery is discharging more than 100A, then -100 should be set as the threshold.

## Defining Alerts

For each Alert, e.g. True Wind Speed, you can define multiple thresholds, e.g. a Warning at 15kts, an Alarm at 20kts and then an Emergency at 25kts.

For decreasing values, e.g. Depth Below Keel, the alerts are triggered when the value falls below the defined thresholds, e.g. Warning at 10m and then an Alarm at 5m.

## Setting Alerts

Once you have defined the desired alerts on the Settings Page, you can then enable ![enable](assets/icons/__THEME__/check_circle.png) and disable ![disable](assets/icons/__THEME__/cancel.png) them. Once enabled, the alerts stay in effect through SignalK server restarts.

## Cleaning Server Config

When Alerts are applied to the server, the "baseDeltas.json" config file is updated with the required Zone configurations. When you disable an Alert a Normal/Nominal Zone has to be created to update the notification state and this is also reflected in the "baseDeltas.json" config file.

If want to fully remove the config from the "baseDeltas.json" file, then you are given the chance when you delete an Alert from the Setting Page.

**Important**: make sure you disable the Alert before you delete it.

**Note:** if you elect to remove the file entry this also has the effect of removing all metadata for the associated path. Therefore if you rely on this metadata for other functions, the SignalK server must be restarted to restore the default metadata.