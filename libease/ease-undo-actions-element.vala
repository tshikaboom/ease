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
 * Undos the addition of an {@link Element} to a {@link Slide}.
 */
public class Ease.ElementAddUndoAction : UndoItem
{
	/**
	 * The {@link Element} that was added.
	 */
	private Element element;
	
	/**
	 * Creates an ElementAddUndoAction.
	 *
	 * @param e The element that was added.
	 */
	public ElementAddUndoAction(Element e)
	{
		element = e;
	}
	
	/**
	 * Applies the action, removing the {@link Element}.
	 */
	public override UndoItem apply()
	{
		var action = new ElementRemoveUndoAction(element);
		element.parent.remove_element(element);
		return action;
	}
}

/**
 * Undos the removal of an {@link Element} from a {@link Slide}.
 */
public class Ease.ElementRemoveUndoAction : UndoItem
{
	/**
	 * The {@link Element} that was removed.
	 */
	private Element element;
	
	/**
	 * The {@link Slide} that the Element was removed from.
	 */
	private Slide slide;
	
	/**
	 * The index of the Element in the Slide's stack.
	 */
	int index;
	
	/**
	 * Creates an ElementRemoveUndoAction. Note that this method references
	 * {@link Element.parent}. Therefore, the action must be constructed
	 * before the Element is actually removed.
	 *
	 * @param e The element that was added.
	 */
	public ElementRemoveUndoAction(Element e)
	{
		element = e;
		slide = e.parent;
		index = e.parent.index_of(e);
	}
	
	/**
	 * Applies the action, restoring the {@link Element}.
	 */
	public override UndoItem apply()
	{
		slide.add_element(index, element);
		return new ElementAddUndoAction(element);
	}
}

