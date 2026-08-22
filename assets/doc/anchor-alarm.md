# Anchor Alarm

Ensure the **signalk-anchoralarm-plugin** is installed and configured on signalk.

**Note:** to be able to set the **Anchor Alarm**, the device must be given "admin" permission to SignalK, see [Authentication](doc:authentication.md).

Prior to dropping your anchor, a ring of the **Sample Radius** size is displayed around your current position. This can be temporarily resized using the ![decrees](assets/icons/__THEME__/remove.png) and ![increase](assets/icons/__THEME__/add.png) buttons. Hold down the button to rapidly resize.

If you start from the position where you want to end up, press the ![boat](assets/icons/__THEME__/close.png) button. This will lock the sample radius at the current position. You can then move forward to set the anchor guided by the sample radius.

When you drop your anchor press the ![anchor](assets/icons/__THEME__/anchor.png) button. Then payout your chain/rode. Once dug-in and pulling back, press the ![set radius](assets/icons/__THEME__/cancel.png) button to set the alarm radius. The **Alarm Radius Fudge Factor** setting in the **signalk-anchoralarm-plugin** gets added to your current distance from the anchor.

Once set, you can unlock and drag the anchor to move it and resize the alarm radius by dragging on the **Radius** text.

**Touchscreen Tip:** when resizing the alarm radius by dragging on the size text, drag down a small amount to see the changing radius value.

**Note:** the alarm radius cannot be set less than the current boat position and any attempt will set the radius to the boat position plus 5m.

![unlock](assets/icons/__THEME__/lock.png) Locks/Unlocks the ability to adjust or raise the anchor
![boat](assets/icons/__THEME__/close.png) Marks the current boat position where you want to end up after setting the anchor
![anchor](assets/icons/__THEME__/anchor.png) Marks the anchor at the current boat position
![set radius](assets/icons/__THEME__/cancel.png) Sets the alarm radius to the current boat position plus Fudge Factor
![decrees](assets/icons/__THEME__/remove.png) Decreases the sample or alarm radius
![increase](assets/icons/__THEME__/add.png) Increases the sample or alarm radius
![anchor](assets/icons/__THEME__/raise-anchor.png) Raise the anchor

**Note:** once **Unlocked**, swiping within the Box will not change the Page. Either re-lock or swipe on a different Box. The Box will automatically re-lock in 2 minutes.

[Charts/Maps](doc:charts.md) can be display if configured in your SignalK server.
