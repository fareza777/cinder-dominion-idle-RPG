# Equipment clarity — 0.15

The equipment modal now shows an item summary, current slot occupant, total-build before/after values, workshop link and item protection controls. Comparison uses isolated copies of state and the real stat calculation, including fighting style, talents, relics, refuge bonuses and applicable potion buffs.

Axes, picks and rods show a representative activity duration from the real production timer. This includes existing mastery/refuge modifiers. The UI explicitly states that rarity does not change tool speed. It avoids presenting equipment rarity as a speed upgrade.

Equip now keeps the modal open only after successful mutation and refreshes it to Already equipped. During combat, changing equipment is disabled with a visible explanation. The prior flow dismissed even after a rejected equip command. Lock/favorite actions and salvage protection remain unchanged.

Verification: 67 essential checks passed, including three added checks for read-only preview, agreement with actual equipped stats and real tool duration. Five isolated phone captures cover candidate gear, equipped status, tool comparison, combat lock and large text. Actual equip action and disabled combat state verified. No physical-device or long-duration balance test in this iteration. Android APK remains debug signed.
