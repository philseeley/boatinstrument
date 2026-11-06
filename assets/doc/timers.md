# Timers

Timers are defined in the **Timers Setup** Box and must be Stopped or Started at least once before they can be selected for display in the **Timer Display** Box.

# Setup

There are two types of timer, **Absolute** and **Delta**. **Absolute** Timers expire at a defined time and **Delta** Timers are relative to when they are started.

Only **Delta** Timers can be restarted or stopped from the **Timer Display** Box.

All Timers must have an **ID**, but you can define multiple Timers with the same **ID**, e.g. you could define three **Delta** Timers for 20, 10 and 5 minutes intervals all with the **ID** "start". Only one of these can be active at a time.

## Display

If **Backup Alarm** is enabled, then if the Timer has expired for **Backup Alarm Delay** minutes, the selected **Alarm Level** sound is played. This is primarily designed for a watch timer, where the Alert sound is subtle, but the Alarm sounds an Emergency. As the delays are device specific, you can have a setup where the off-watch person is alerted only if the on-watch person fails to respond to both the Alert and the Alarm sounds.

Setting the Alert/Alarm Level to Normal/Nominal will disable the audio alert.

**Note:** Timer Display settings are Per-Box, so you are able to display the same Timer on multiple Pages. If the Settings for the same Timer differ, then the maximum values are use for the audio alerts.