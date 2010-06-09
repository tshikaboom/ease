/*  Ease, a GTK presentation application
    Copyright (C) 2010 Nate Stedman

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
 * Interface element for manipulating the size of {@link Actor}s.
 */
public class Ease.Handle : Clutter.Texture
{	
	// the position of this handle
	private HandlePosition position;
	
	// if the handle has been "flipped"
	private bool flipped = false;
	
	// constants
	public const float SIZE = 20;
	public const string W_PATH = "/usr/local/share/ease/svg/handle-white.svg";
	public const string B_PATH = "/usr/local/share/ease/svg/handle-black.svg";
	
	public Handle(HandlePosition pos)
	{
		// set the handle's position
		position = pos;

		// load the handle texture
		filename = W_PATH;

		// set the handle's anchor
		set_anchor_point(width / 2, height / 2);
		
		// react to clicks
		reactive = true;
	}
	
	public void drag(float change_x, float change_y, Actor target, bool prop)
	{
		switch (position)
		{
			case HandlePosition.TOP_LEFT:
				target.translate(change_x, change_y);
				target.resize(-change_x, -change_y, prop);
				break;
				
			case HandlePosition.TOP_RIGHT:
				target.translate(0, change_y);
				target.resize(change_x, -change_y, prop);
				break;
				
			case HandlePosition.TOP:
				target.translate(0, change_y);
				target.resize(0, -change_y, false);
				break;
				
			case HandlePosition.BOTTOM:
				target.resize(0, change_y, false);
				break;
				
			case HandlePosition.LEFT:
				target.translate(change_x, 0);
				target.resize(-change_x, 0, false);
				break;
				
			case HandlePosition.RIGHT:
				target.resize(change_x, 0, false);
				break;
				
			case HandlePosition.BOTTOM_LEFT:
				target.translate(change_x, 0);
				target.resize(-change_x, change_y, prop);
				break;
				
			case HandlePosition.BOTTOM_RIGHT:
				target.resize(change_x, change_y, prop);
				break;
		}
	}
	
	public void drag_from_center(float change_x, float change_y, Actor target,
	                             bool prop)
	{
		switch (position)
		{
			case HandlePosition.TOP_LEFT:
				target.translate(change_x, change_y);
				target.resize(-change_x * 2, -change_y * 2, false);
				break;
				
			case HandlePosition.TOP_RIGHT:
				target.translate(-change_x, change_y);
				target.resize(change_x * 2, -change_y * 2, prop);
				break;
				
			case HandlePosition.TOP:
				target.translate(0, change_y);
				target.resize(0, -change_y * 2, false);
				break;
				
			case HandlePosition.BOTTOM:
				target.translate(0, -change_y);
				target.resize(0, change_y * 2, false);
				break;
				
			case HandlePosition.LEFT:
				target.translate(change_x, 0);
				target.resize(-change_x * 2, 0, false);
				break;
				
			case HandlePosition.RIGHT:
				target.translate(-change_x, 0);
				target.resize(change_x * 2, 0, false);
				break;
				
			case HandlePosition.BOTTOM_LEFT:
				target.translate(change_x, -change_y);
				target.resize(-change_x * 2, change_y * 2, prop);
				break;
				
			case HandlePosition.BOTTOM_RIGHT:
				target.translate(-change_x, -change_y);
				target.resize(change_x * 2, change_y * 2, prop);
				break;
		}
	}
	
	public void reposition(Clutter.Actor selection)
	{
		switch (position)
		{
			case HandlePosition.TOP_LEFT:
				x = selection.x;
				y = selection.y;
				break;
				
			case HandlePosition.TOP_RIGHT:
				x = selection.x + selection.width;
				y = selection.y;
				break;
				
			case HandlePosition.TOP:
				x = selection.x + selection.width / 2;
				y = selection.y;
				break;
				
			case HandlePosition.LEFT:
				x = selection.x;
				y = selection.y + selection.height / 2;
				break;
				
			case HandlePosition.RIGHT:
				x = selection.x + selection.width;
				y = selection.y + selection.height / 2;
				break;
				
			case HandlePosition.BOTTOM_LEFT:
				x = selection.x;
				y = selection.y + selection.height;
				break;
				
			case HandlePosition.BOTTOM_RIGHT:
				x = selection.x + selection.width;
				y = selection.y + selection.height;
				break;
				
			case HandlePosition.BOTTOM:
				x = selection.x + selection.width / 2;
				y = selection.y + selection.height;
				break;
		}
	}
	
	/**
	 * Flips the colors of the handle.
	 */
	public void flip()
	{
		if (flipped)
		{
			filename = W_PATH;
		}
		else
		{
			filename = B_PATH;
		}
		
		flipped = !flipped;
	}
}

