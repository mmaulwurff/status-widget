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

    let result = sw_Messages.create();
    let player = players[consolePlayer].mo;

    int basicArmorValue = player.countInv("BasicArmor");
    watch(basicArmorValue, savedStatus, "basic_armor", StringTable.localize("$SW_ARMOR"), result);

    int hexenArmorValue = getHexenArmor(player);
    if (hexenArmorValue >= 0)
    {
      watch( hexenArmorValue
           , savedStatus
           , "hexen_armor"
           , StringTable.localize("$SW_ARMOR_CLASS")
           , result
           );
    }

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  // Taken from StatusBar.getArmorSavePercent().
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

  private
  void watch(int newValue, Dictionary savedStatus, string key, string name, sw_Messages result)
  {
    int oldValue = savedStatus.at(key).toInt();

    if (oldValue == newValue) return;

    result.push(name, oldValue, newValue);
    savedStatus.insert(key, string.format("%d", newValue));
  }

  private sw_Cvar mIsEnabled;

} // class sw_ArmorTracker
