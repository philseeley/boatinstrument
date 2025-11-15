# Application Pages

The Boat Instrument shows a number of Pages and swiping left/right moves between them. Swiping down reveals additional options:

![night mode](assets/icons/__THEME__/mode_night.png) Enables/Disables Night Mode
![full screen](assets/icons/__THEME__/fullscreen.png) Enables/Disables Full Screen
![brightness](assets/icons/__THEME__/brightness_7.png) If enabled, cycles the brightness on supported platforms
![page rotation](assets/icons/__THEME__/sync_alt.png) Toggles the Auto-Page rotation. Set the per-page delays in the page list. Pages without delays are not shown
![notifications](assets/icons/__THEME__/format_list_bulleted.png) Shows the notification log
![unmute](assets/icons/__THEME__/volume_off.png) Unmutes notifications
![pages](assets/icons/__THEME__/web.png) Displays the list of pages, see **Editing Pages** below

Notifications sent from SignalK are displayed at the bottom of the app, with appropriate sounds if requested by the server. If repeat notifications are sent with the same severity, then the number displayed for normal/nominal is 1, alert is 5, warn is 10, alarm is 20 and emergency is 30.

## Editing Pages

Pages can be created and edited using the buttons on the page list:

![add](assets/icons/__THEME__/add.png) Adds a new page
![edit](assets/icons/__THEME__/edit.png) Edits the page contents
![copy page](assets/icons/__THEME__/content_copy.png) Copy/clone a Page
![reorder](assets/icons/__THEME__/drag_handle.png) Drag handle for reordering pages
![delete](assets/icons/__THEME__/delete.png) Delete the page

Each Page is made up of multiple Page Rows (Red), containing multiple Columns (Orange), containing multiple Rows (Yellow), containing multiple Boxes (Blue). Use the coloured arrows to add Page elements.

**Hint:** sometimes you may need to temporarily resize a Box to show all the buttons.

The contents of each Box is selected through the ![box selection](assets/icons/__THEME__/format_list_bulleted.png) menu button.

If the Box has settings, these are configured through the ![settings](assets/icons/__THEME__/settings.png) buttons in the top right corner of the Box. The Blue button sets the Box instance settings and the White/Black button sets the Box Type settings that are shared between all instances of the Box.

In the Box selection menu, Boxes containing dials or other non-digital displays are marked ![gauge](assets/icons/__THEME__/speed.png) and Graphs are marked ![graph](assets/icons/__THEME__/show_chart.png). Boxes marked ![experimental](assets/icons/__THEME__/science.png) are experimental and may not function as expected, but any [feedback](https://github.com/philseeley/boatinstrument/issues) will be gratefully received. To uses these Boxes, you must enable **Experimental Boxes** in the **Advanced** Settings.

The sizes of the Page elements can be adjusted by dragging the coloured Box borders. If the last Box in a Row or Column is deleted, the Row or Column is also deleted.

Whilst in **Edit Mode** dummy values are shown, usually the value "12.3". This allows you to visualise what the Boxes will look like when running.

# SignalK Server Settings

If **mDNS** is enabled in your server's settings, your server should be automatically discovered. If discovery does not work, disable **Auto Discovery** and enter your server's URL.

The **Subscription Min Period** is the minimum time between data updates. Increasing this value will reduce the load on your SignalK server.

If no data is received within the **Connection Timeout** the connection is reopened.

If a Box receives no data within the **Real-time Data Timeout** the box is cleared and a "-" is generally displayed. For data infrequently updated by SignalK the **Infrequent Data Timeout** is used.

You can set additional HTTP Headers if the connection to the SignalK server requires them, e.g. for proxies.

In **Demo Mode** the app connects to https://demo.signalk.org.

Certain Boxes, like the **Autopilot Controls**, and [App Remote Control](doc:remote-control.md) require [Authentication](doc:authentication.md) to be set-up.

The **Settings** page provides additional options:

![export](assets/icons/__THEME__/share.png) Shares/Exports the Settings
![import](assets/icons/__THEME__/file_open.png) Imports Settings from a file
![subscriptions](assets/icons/__THEME__/mediation.png) Show the current SignalK Subscriptions
![error log](assets/icons/__THEME__/notes.png) Shows the message/error log
![change log](assets/icons/__THEME__/change_history.png) From the Help page, shows the change log
![export file](assets/icons/__THEME__/upload.png) From the Error Log page, Export a Config or Log file

# Command Line Options

If setting time is enabled via the "--enable-set-time" command line option and "Set Time" is enabled in the Advanced Settings, then **sudo** will be used to set the time from "navigation.datetime".

Additional [documentation](https://philseeley.github.io/docs/boatinstrument/main.html) is available online.

# Issues and Feedback

If you encounter any issues or have suggestions for new Boxes or other improvements, then please raise an [Issue](https://github.com/philseeley/boatinstrument/issues).