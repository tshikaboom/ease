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
	 * action.
	 */
	public abstract void apply();
}

/**
 * {@link UndoAction} for moving or resizing an {@link Actor}.
 */
public class Ease.MoveUndoAction : UndoAction
{
	private Actor actor;
	private float x_pos;
	private float y_pos;
	private float width;
	private float height;
	
	/**
	 * Creates a new MoveUndoAction.
	 *
	 * @param actor The {@link Actor} this applies to.
	 * @param x The origin X position of the {@link Actor}.
	 * @param y The origin Y position of the {@link Actor}.
	 * @param w The origin width of the {@link Actor}
	 * @param h The origin height position of the {@link Actor}
	 */
	public MoveUndoAction(Actor a, float x, float y, float w, float h)
	{
		actor = a;
		x_pos = x;
		y_pos = y;
		width = w;
		height = h;
	}
	
	public override void apply()
	{
		actor.translate(x_pos - actor.x, y_pos - actor.y);
		actor.resize(width - actor.width, height - actor.height, false);
	}
}

