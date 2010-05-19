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
public class Ease.UndoController
{
	private Gee.LinkedList<UndoAction> undos;
	
	public UndoController()
	{
		undos = new Gee.LinkedList<UndoAction>();
	}
	
	/**
	 * Returns true if there is an action available to undo.
	 */
	public bool can_undo()
	{
		return undos.size > 0;
	}
	
	/**
	 * Undoes the first available {@link UndoAction}.
	 */
	public void undo()
	{
		undos.poll_head().apply();
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
}
