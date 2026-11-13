# Anchor Alarm

Ensure the **signalk-anchoralarm-plugin** is installed and configured on signalk.

**Note:** to be able to set and adjust the **Anchor Alarm**, the device must be given "admin" permission to SignalK, see [Authentication](doc:authentication.md). No permissions are required to display the Anchor Alarm.

![anchor alarm](assets/doc/anchor-alarm.png)

The box has 3 main sets of controls:
- Anchoring - buttons for setting your anchor and initial alarm radius.
- Post-Anchoring - buttons for adjusting the anchor position and alarm radius.
- Display - buttons to change what is shown.

## Anchoring

Prior to dropping your anchor, a ring of the **Sample Radius** size is displayed around your current position. This can be temporarily resized using the the Post-Anchoring ![decrease](assets/icons/__THEME__/remove.png) and ![increase](assets/icons/__THEME__/add.png) buttons. Hold down the button to rapidly resize.

In a crowded anchorage, you can better position your anchor by starting from your desired final position and pressing the ![boat](assets/icons/__THEME__/location.png) button. This will lock the sample radius at the current position. You can then move forward to drop your anchor guided by the sample radius and the apparent wind indicator.

When you drop your anchor press the ![anchor](assets/icons/__THEME__/anchor.png) button. Then payout your chain/rode. Once dug-in and pulling back, press the ![set radius](assets/icons/__THEME__/cancel.png) button to set the alarm radius. The **Alarm Radius Fudge Factor** setting in the **signalk-anchoralarm-plugin** gets added to your current distance from the anchor.

![boat](assets/icons/__THEME__/location.png) Marks the current boat position where you want to end up after setting your anchor
![anchor](assets/icons/__THEME__/anchor.png) Marks the anchor at the current boat position
![set radius](assets/icons/__THEME__/cancel.png) Sets the alarm radius to the current boat position plus the Fudge Factor

## Post-Anchoring

Once set, you can unlock and drag the anchor to move it and resize the alarm radius by dragging on the **Radius** text.

**Touchscreen Tip:** when resizing the alarm radius by dragging on the size text, drag down a small amount to see the changing radius value.

**Note:** the alarm radius cannot be set less than the current boat position and any attempt will set the radius to the boat position plus 5m.

![unlock](assets/icons/__THEME__/lock.png) Locks/Unlocks the ability to adjust or raise the anchor
![decrease](assets/icons/__THEME__/remove.png) Decreases the alarm radius
![increase](assets/icons/__THEME__/add.png) Increases the alarm radius
![anchor](assets/icons/__THEME__/raise-anchor.png) Raise the anchor

**Note:** once **Unlocked**, swiping within the Box will not change the Page. Either re-lock or swipe on a different Box. The Box will automatically re-lock in 2 minutes.

## Display

[Charts/Maps](doc:charts.md) can be display if configured in your SignalK server.

On Android and iOS, when returning to your boat in a crowded anchorage, especially after dark, you can show your position and direction by toggling the ![device position](assets/icons/__THEME__/location.png) button. A circle indicating the reported location accuracy is shown and the heading accuracy is shown with two direction lines.

**Note:** you must allow **Precise Location** permission to see your current location.

![device position](assets/icons/__THEME__/location.png) Show/Hide your device's location and direction.
![show/hide map](assets/icons/__THEME__/map.png) Show/Hide the Chart/Map
![zoom in](assets/icons/__THEME__/add.png) Zooms in
![reset](assets/icons/__THEME__/all_out.png) Resets the view around the anchor
![zoom out](assets/icons/__THEME__/remove.png) Zooms out
