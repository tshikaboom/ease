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
 * Controls undo and redo actions.
 *
 * Each {@link EditorWindow} has an UndoController that manages undo actions.
 */
public class Ease.UndoController : Object
{
	private Gee.LinkedList<UndoAction> undos = new Gee.LinkedList<UndoAction>();
	private Gee.LinkedList<UndoAction> redos = new Gee.LinkedList<UndoAction>();
	
	public UndoController() { }
	
	/**
	 * Returns true if there is an action available to undo.
	 */
	public bool can_undo()
	{
		return undos.size > 0;
	}
	
	/**
	 * Returns true if there is an action available to redo.
	 */
	public bool can_redo()
	{
		return redos.size > 0;
	}
	
	/**
	 * Undoes the first available {@link UndoAction} in the undo queue.
	 */
	public void undo()
	{
		add_redo_action(undos.poll_head().apply());
	}
	
	/**
	 * Redoes the first available {@link UndoAction} in the redo queue.
	 */
	public void redo()
	{
		add_action(redos.poll_head().apply());
	}
	
	/**
	 * Clears the redo queue.
	 */
	public void clear_redo()
	{
		redos.clear();
	}
	
	/**
	 * Adds a new {@link UndoAction} as the first action.
	 *
	 * @param action The new {@link UndoAction}.
	 */
	public void add_action(UndoAction action)
	{
		undos.offer_head(action);
	}
	
	/**
	 * Adds a new {@link UndoAction} as the first action.
	 *
	 * @param action The new {@link UndoAction}.
	 */
	private void add_redo_action(UndoAction action)
	{
		redos.offer_head(action);
	}
}
