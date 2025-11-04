# Remote Control

An instance of the app can be controlled remotely, either individually or as part of a group.

To enable remote control, the **Allow Remote Control** setting in the main **Settings** page must be enabled and the **App ID** set to a unique value. If you want to control the app as part of a group, the **Group ID** or **Supplementary Group IDs** must also be set.

Both the **Controlled** and **Controlling** apps must have a read/write **Auth Token** set in the main **Settings** page, see [Authentication](doc:authentication.md) for more details.

On the **Controlling** apps, one or more **Remote Control** boxes can then be set-up as required.

## Main Group ID

The app's **Main Group ID** is normally used to control pages in a group, so ensure that each device that shares a **Main Group ID** have the same set of page names. The page contents is device specific. If the page names differ between devices with the same **Main Group ID**, the outcome is not deterministic.

For example, multiple displays at the mast could be put in a "mast" group and a set of pages for racing created. The page names would be the same on each display, but with different contents, e.g. "start", "up wind" and "down wind". Pre-set Text pages could be used to display crew commands.

## Supplementary Group IDs 

A device can be added to additional **Supplementary Group IDs**. These would normally be used to control aspects like display brightness.

For example, a set of devices whose **Main Group IDs** are "mast" and "cockpit" could also be in the **Supplementary Group ID** "deck". This would allow the brightness of all deck mounted devices to be controlled simultaneously. Further adding these and all other devices to a "boat" group would allow the brightness of the entire boat to be set.

In situations where page control is desirable, but the **Main Group ID** is already set for another purpose, a set of page names can be manually created for control by a **Supplementary Group ID**. For example, a manually added page name of "anchor" could be controlled by the **Supplementary Group ID** "boat". This would allow you to switch all devices on the boat to that page if they have it defined. 