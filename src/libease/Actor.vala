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
 * The basic Ease actor, subclassed for different types of
 * {@link Element}.
 *
 * The Actor class should never be instantiated - instead,
 * subclasses such as {@link TextActor} and {@link ImageActor}
 * are placed on a {@link SlideActor} to form Ease presentations.
 */
public class Ease.Actor : Clutter.Group
{
	// the contents of the actor
	protected Clutter.Actor contents;

	// the element this actor represents
	public Element element;

	// where this actor is (editor, player, sidebar)
	public ActorContext context;
	
	// if the actor is a slide background
	public bool is_background;

	/**
	 * Instantiate a new Actor
	 * 
	 * Instantiates the Actor base class. In general, this should only be
	 * called by subclasses.
	 *
	 * @param e The {@link Element} this Actor represents.
	 * @param c The context of this Actor - sidebar, presentation, editor.
	 */
	public Actor(Element e, ActorContext c)
	{
		element = e;
		context = c;
		is_background = false;
	}
	
	/**
	 * Move this Actor and update its {@link Element}
	 * 
	 * Used in the editor and tied to Clutter MotionEvents.
	 *
	 * @param x_change The amount of X motion.
	 * @param y_change The amount of Y motion.
	 */
	public void translate(float x_change, float y_change)
	{
		x += x_change;
		y += y_change;
		
		element.x = x;
		element.y = y;
	}
	
	/**
	 * Resize this Actor and update its {@link Element}
	 * 
	 * Used in the editor and tied to Clutter MotionEvents on handles.
	 *
	 * @param w_change The amount of width change.
	 * @param h_change The amount of height change.
	 * @param proportional If the resize should be proportional only
	 */
	public void resize(float w_change, float h_change, bool proportional)
	{
		if (proportional)
		{
			if (w_change / h_change > width / height)
			{
				w_change = h_change * (width / height);
			}
			else if (w_change / h_change < width / height)
			{
				h_change = w_change * (height / width);
			}
		}
	
		if (width + w_change > 1)
		{
			width += w_change;
			contents.width += w_change;
		}
		if (height + h_change > 1)
		{
			height += h_change;
			contents.height += h_change;
		}
		
		element.width = width;
		element.height = height;	
	}
}

