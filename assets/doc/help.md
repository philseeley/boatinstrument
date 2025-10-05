The display shows a number of Pages and swiping left/right moves between them. Swiping down and selecting ![Image](assets/icons/__THEME__/web.png) shows the list of Pages. Press the ![Image](assets/icons/__THEME__/edit.png) button to edit a Page. Each Page is made up of multiple Page Rows (Red), containing multiple Columns (Orange), containing multiple Rows (Yellow), containing multiple Boxes (Blue). Use the coloured arrows to add Page elements.

**Hint:** sometimes you may need to temporarily resize a Box to show all the buttons.

The contents of each Box is selected through the ![Image](assets/icons/__THEME__/format_list_bulleted.png) button. If the Box has settings, these are set through the ![Image](assets/icons/__THEME__/settings.png) buttons in the top right corner of the Box. The Blue button sets the Per-Box settings and the White/Black button sets the Box Type settings that are shared between all instances of the Box. Boxes containing dials or other non-digital displays are marked ![Image](assets/icons/__THEME__/speed.png) and Graphs are marked ![Image](assets/icons/__THEME__/show_chart.png). The sizes of the Page elements can be adjusted by dragging the coloured Box borders. If the last Box in a Row or Column is deleted, the Row or Column is also deleted.

Whilst in **Edit Mode** dummy values are shown, usually the value "12.3". This allows you to visualise what the Boxes will look like when running.

Swiping up or pressing the back button hides the top bar.

For **Auto Discovery** of your SignalK server, mDNS must be turned on in your server's settings. If discovery does not work, enter your server's URL.

The **Subscription Min Period** is the minimum time between data updates. Increasing this value will reduce the load on your SignalK server.

If no data is received within the **Connection Timeout** the connection is reopened.

If a Box receives no data within the **Data Timeout** the box is cleared and a "-" is generally displayed.

You can set additional HTTP Headers if the connection to the SignalK server requires them, e.g. for proxies.

Notifications sent from SignalK are displayed at the bottom of the app, with appropriate sounds if requested by the server. If repeat notifications are sent with the same severity, then the number displayed for normal/nominal is 1, alert is 5, warn is 10, alarm is 20 and emergency is 30.

In **Demo Mode** the app connects to https://demo.signalk.org.

Boxes marked ![Image](assets/icons/__THEME__/science.png) are experimental and may not function as expected, but any feedback will be gratefully received. You must enable Experimental Boxes in the **Advanced** Settings.
        
If setting time is enabled via the "--enable-set-time" command line option and "Set Time" is enabled in the Advanced Settings, then **sudo** will be used to set the time from **navigation.datetime**.

![Image](assets/icons/__THEME__/mode_night.png) Enables/Disables Night Mode
![Image](assets/icons/__THEME__/fullscreen.png) Enables/Disables Full Screen
![Image](assets/icons/__THEME__/brightness_7.png) Cycles the brightness on supported platforms
![Image](assets/icons/__THEME__/sync_alt.png) Toggles the Auto-Page rotation. Set the per-page delays in the page list. Pages without delays are not shown
![Image](assets/icons/__THEME__/format_list_bulleted.png) Shows the notification log
![Image](assets/icons/__THEME__/volume_off.png) Unmutes notifications
![Image](assets/icons/__THEME__/content_copy.png) Copy/Clone a Page
![Image](assets/icons/__THEME__/drag_handle.png) Drag handle for reordering pages
![Image](assets/icons/__THEME__/share.png) Shares/Exports the Settings
![Image](assets/icons/__THEME__/file_open.png) Imports Settings from a file
![Image](assets/icons/__THEME__/mediation.png) Show the current SignalK Subscriptions
![Image](assets/icons/__THEME__/notes.png) Shows the message/error log
![Image](assets/icons/__THEME__/change_history.png) Shows the change log
