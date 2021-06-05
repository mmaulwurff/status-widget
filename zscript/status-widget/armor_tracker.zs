/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2021
 *
 * This file is part of Status-Widget.
 *
 * Status-Widget is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Status-Widget is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Status-Widget.  If not, see <https://www.gnu.org/licenses/>.
 */

class sw_ArmorTracker : sw_Tracker
{

  override
  void initialize()
  {
    mIsEnabled = sw_Cvar.from("sw_enable_armor");
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    if (!mIsEnabled.getBool()) return NULL;

    sw_Messages result = NULL;
    let player = players[consolePlayer].mo;

    // Basic Armor
    {
      int newValue = player.countInv("BasicArmor");
      int oldValue = savedStatus.at(BASIC_ARMOR_KEY).toInt();
      if (oldValue != newValue)
      {
        string name = StringTable.localize("$SW_ARMOR");
        let arm = player.findInventory("BasicArmor");
        int maxValue = arm ? arm.maxAmount : -1;
        if (result == NULL) result = sw_Messages.create();
        result.push(name, oldValue, newValue, maxValue);
        savedStatus.insert(BASIC_ARMOR_KEY, string.format("%d", newValue));
      }
    }

    // Hexen Armor
    {
      int newValue = getHexenArmor(player);
      if (newValue >= 0)
      {
        int oldValue = savedStatus.at(HEXEN_ARMOR_KEY).toInt();
        if (oldValue != newValue)
        {
          string name = StringTable.localize("$SW_ARMOR_CLASS");
          if (result == NULL) result = sw_Messages.create();
          result.push(name, oldValue, newValue);
          savedStatus.insert(HEXEN_ARMOR_KEY, string.format("%d", newValue));
        }
      }
    }

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  const BASIC_ARMOR_KEY = "basic_armor";
  const HEXEN_ARMOR_KEY = "hexen_armor";

  /// Taken from StatusBar.getArmorSavePercent().
  private static
  int getHexenArmor(PlayerPawn player)
  {
    double add = 0;

    let harmor = HexenArmor(player.findInventory("HexenArmor"));
    if (harmor != NULL)
    {
      add = harmor.Slots[0] + harmor.Slots[1] + harmor.Slots[2] + harmor.Slots[3] + harmor.Slots[4];
      if (add == 0) return -1;
    }

    // Hexen counts basic armor also so we should too.
    let armor = BasicArmor(player.findInventory("BasicArmor"));
    if (armor != NULL && armor.amount > 0)
    {
      add += armor.savePercent * 100;
    }

    return int(add) / 5;
  }

  private sw_Cvar mIsEnabled;

} // class sw_ArmorTracker
