Ensure the **signalk-anchoralarm-plugin** is installed and configured on signalk.

**Note:** to be able to set the **Anchor Alarm**, the device must be given "admin" permission to SignalK, see [Authentication](doc:authentication.md).

When you drop your anchor press the ![anchor](assets/icons/__THEME__/anchor.png) button. Then payout your chain/rode. Once dug-in, press the ![set radius](assets/icons/__THEME__/cancel.png) button to set the alarm radius. The **Alarm Radius Fudge Factor** setting in the **signalk-anchoralarm-plugin** gets added to your current distance from the anchor.

Once set, you can unlock and drag the anchor to move it and resize the alarm radius by dragging on the **Radius** text.

**Note:** the alarm radius cannot be set less than the current boat position and any attempt will set the radius to the boat position plus 5m.

![unlock](assets/icons/__THEME__/lock.png) Locks/Unlocks the ability to adjust or raise the anchor
![anchor](assets/icons/__THEME__/anchor.png) Marks the anchor at the current boat position
![set radius](assets/icons/__THEME__/cancel.png) Sets the alarm radius to the current boat position plus Fudge Factor
![decrees](assets/icons/__THEME__/remove.png) Decreases the alarm radius by 5m
![increase](assets/icons/__THEME__/add.png) Increases the alarm radius by 5m
![anchor](assets/icons/__THEME__/raise-anchor.png) Raise the anchor

**Note:** once **Unlocked**, swiping within the Box will not change the Page. Either re-lock or swipe on a different Box. The Box will automatically re-lock in 2 minutes.

Charts/maps can be displayed from the [@signalk/charts-plugin](https://github.com/SignalK/charts-plugin#readme), which can serve local or cached online charts.

![increase](assets/icons/__THEME__/add.png) Zooms in
![decrees](assets/icons/__THEME__/all_out.png) Resets the view around the anchor
![decrees](assets/icons/__THEME__/remove.png) Zooms out
