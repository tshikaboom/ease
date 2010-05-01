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

namespace Ease
{
	public class Actor : Clutter.Group
	{
		// the contents of the actor
		protected Clutter.Actor contents;

		// the element this actor represents
		public Element element;

		// where this actor is (editor, player, sidebar)
		public ActorContext context;

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
		}
	}
}
