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

class sw_Options
{

  static
  sw_Options from()
  {
    let result = new("sw_Options");
    result.init();
    return result;
  }

  double getScale() const { return mScale.getDouble(); }
  double getX() const { return mX.getDouble(); }
  double getY() const { return mY.getDouble(); }
  double getOpacity() const { return mOpacity.getDouble(); }

  string getBackgroundColor() const { return mBackgroundColor.getString(); }

  int getLimit() const { return mLimit.getInt(); }
  int getAlignment() const { return mAlignment.getInt(); }
  int getLifetime() const { return mLifetime.getInt(); }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void init()
  {
    mScale   = load("sw_scale");
    mX       = load("sw_x");
    mY       = load("sw_y");
    mOpacity = load("sw_opacity");

    mBackgroundColor = load("sw_background_color");

    mLimit     = load("sw_limit");
    mAlignment = load("sw_alignment");
    mLifetime  = load("sw_lifetime");
  }

  private static
  sw_Cvar load(string cvarName)
  {
    return sw_Cvar.from(cvarName);
  }

  private sw_Cvar mScale;
  private sw_Cvar mX;
  private sw_Cvar mY;
  private sw_Cvar mOpacity;

  private sw_Cvar mBackgroundColor;

  private sw_Cvar mLimit;
  private sw_Cvar mAlignment;
  private sw_Cvar mLifetime;

} // class sw_Options
