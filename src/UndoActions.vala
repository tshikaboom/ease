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
 * Abstract base class for undo actions.
 *
 * Subclasses should override apply() and add a constructor, as well as any
 * needed data fields.
 */
public abstract class Ease.UndoAction : Object
{
	/**
	 * Applies the {@link UndoAction}.
	 *
	 * This method should be overriden by subclasses to undo the appropriate
	 * action. It should return an UndoAction that will redo the UndoAction.
	 */
	public abstract UndoAction apply();
}

/**
 * {@link UndoAction} for moving or resizing an {@link Actor}.
 */
public class Ease.MoveUndoAction : UndoAction
{
	private Element element;
	private float x_pos;
	private float y_pos;
	private float width;
	private float height;
	
	/**
	 * Creates a new MoveUndoAction.
	 *
	 * @param element The {@link Element} this applies to.
	 * @param x The original X position of the {@link Element}.
	 * @param y The original Y position of the {@link Element}.
	 * @param w The original width of the {@link Element}
	 * @param h The original height position of the {@link Element}
	 */
	public MoveUndoAction(Element e, float x, float y, float w, float h)
	{
		element = e;
		x_pos = x;
		y_pos = y;
		width = w;
		height = h;
	}
	
	public override UndoAction apply()
	{
		var ret = new MoveUndoAction(element, element.x, element.y,
		                             element.width, element.height);
		
		element.x = x_pos;
		element.y = y_pos;
		element.width = width;
		element.height = height;
		
		return ret;
	}
}

