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
public class Ease.Handle : Clutter.CairoTexture
{	
	/**
	 * The position of this handle relative to the selection rectangle.
	 */
	private HandlePosition position;
	
	/**
	 * If the handle is being dragged and should alter its appearance.
	 */
	private bool flipped = false;
	
	/**
	 * The size of the handle.
	 */
	private const int SIZE = 35;
	
	/**
	 * Creates a Handle. Does automatically set the Handle's position - call
	 * reposition() to do this.
	 *
	 * @param pos The position of this handle relative to the selection
	 * rectangle.
	 */
	public Handle(HandlePosition pos)
	{
		// set the handle's size
		width = height = surface_width = surface_height = SIZE;
		
		// draw the default handle appearance
		redraw();
		
		// set the handle's position
		position = pos;

		// set the handle's anchor
		set_anchor_point(SIZE / 2, SIZE / 2);
		
		// react to clicks
		reactive = true;
	}
	
	/**
	 * Performs a drag of the handle, updating the selected {@link Actor}'s size
	 * and position.
	 *
	 * @param change_x The x drag distance.
	 * @param change_y The y drag distance.
	 * @param target The actor to update.
	 * @param prop If any scaling should be proportional, if possible.
	 */
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
	
	/**
	 * Performs a drag of the handle, scaling from the center. Updates the
	 * selected {@link Actor}'s size and position.
	 *
	 * @param change_x The x drag distance.
	 * @param change_y The y drag distance.
	 * @param target The actor to update.
	 * @param prop If any scaling should be proportional, if possible.
	 */
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
	
	/**
	 * Places this Handle in its proper location, relative to the selection
	 * rectangle.
	 *
	 * @param selection The selection rectangle to position the Handle around.
	 */
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
		flipped = !flipped;
		redraw();
	}
	
	private void redraw()
	{
		// get a Cairo context
		var cr = create();
		
		// draw a circle
		cr.arc(SIZE / 2, SIZE / 2, SIZE / 4, 0, 2 * 3.1415);
		
		// fill the circle
		if (flipped) cr.set_source_rgba(1, 1, 1, 1);
		else cr.set_source_rgba(0, 0, 0, 1);
		cr.fill_preserve();
		
		// stroke the circle
		if (flipped) cr.set_source_rgba(0, 0, 0, 1);
		else cr.set_source_rgba(1, 1, 1, 1);
		cr.stroke();
	}
}

