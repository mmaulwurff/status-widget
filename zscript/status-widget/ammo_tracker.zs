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

// Some code lifted from gzdoom/wadsrc/static/zscript/ui/statusbar/alt_hud.zs:
/*
** Enhanced heads up 'overlay' for fullscreen
**
**---------------------------------------------------------------------------
** Copyright 2003-2008 Christoph Oelckers
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** 1. Redistributions of source code must retain the above copyright
**    notice, this list of conditions and the following disclaimer.
** 2. Redistributions in binary form must reproduce the above copyright
**    notice, this list of conditions and the following disclaimer in the
**    documentation and/or other materials provided with the distribution.
** 3. The name of the author may not be used to endorse or promote products
**    derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
** IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
** OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
** IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
** NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
** THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**---------------------------------------------------------------------------
**
*/

class sw_AmmoTracker : sw_Tracker
{

  override
  void initialize()
  {
    PlayerInfo player = players[consolePlayer];

    // Order ammo by use of weapons in the weapon slots.
    for (int k = 0; k < PlayerPawn.NUM_WEAPON_SLOTS; ++k)
    {
      int slotsize = player.weapons.slotSize(k);
      for (int j = 0; j < slotsize; ++j)
      {
        let weap = player.weapons.getWeapon(k, j);
        if (weap == NULL) continue;
        let weapondef = getDefaultByType(weap);
        addAmmoFromWeapon(weapondef.ammoType1);
        addAmmoFromWeapon(weapondef.ammoType2);
      }
    }

    // Now check for the remaining weapons that are in the inventory but not in the weapon slots.
    for (Inventory inv = player.mo.Inv; inv; inv = inv.Inv)
    {
      let weap = Weapon(inv);
      if (weap == NULL) continue;
      addAmmoFromWeapon(weap.ammoType1);
      addAmmoFromWeapon(weap.ammoType2);
    }

    mIsEnabled = sw_Cvar.from("sw_enable_ammo");
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    if (!mIsEnabled.getBool()) return NULL;

    let result = sw_Messages.create();

    uint ammosNumber = mAmmos.size();
    let player = players[consolePlayer].mo;
    for (uint i = 0; i < ammosNumber; ++i)
    {
      string ammo = mAmmos[i];
      int oldValue = savedStatus.at(ammo).toInt();
      let inv      = Inventory(player.findInventory(ammo));

      if (inv == NULL) continue;

      int newValue = inv.amount;

      if (oldValue == newValue) continue;

      class<Actor> ammoClass = ammo;
      result.push(getDefaultByType(ammoClass).getTag(), oldValue, newValue, inv.maxAmount);

      savedStatus.insert(ammo, string.format("%d", newValue));
    }

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void addAmmoFromWeapon(class<Inventory> ammoType)
  {
    if (ammoType == NULL) return;

    let ammodef = GetDefaultByType(ammoType);
    if (ammodef == NULL || ammodef.bInvBar) return;

    string ammoName = ammoType.getClassName();
    if (mAmmos.find(ammoName) != mAmmos.size()) return;

    mAmmos.push(ammoName);
  }

  private Array<string> mAmmos;
  private sw_Cvar       mIsEnabled;

} // class sw_AmmoTracker
