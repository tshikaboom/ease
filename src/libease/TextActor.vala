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
	public class TextActor : Actor
	{
		/**
		 * Instantiates a new TextActor from an Element.
		 * 
		 * TextActor uses {@link Clutter.Text} for rendering.
		 *
		 * @param e The represented element.
		 * @param c The context of this Actor (Presentation, Sidebar, Editor)
		 */
		public TextActor(Element e, ActorContext c)
		{
			base(e, c);
			
			contents = new Clutter.Text();

			// set basic actor properties
			((Clutter.Text)contents).use_markup = true;
			((Clutter.Text)contents).line_wrap = true;
			((Clutter.Text)contents).line_wrap_mode = Pango.WrapMode.WORD_CHAR;
			((Clutter.Text)contents).color = e.color;
			((Clutter.Text)contents).set_markup(e.data.get_str("text"));
			
			// create the font description
			var desc = new Pango.FontDescription();
			desc.set_family(e.data.get_str("font_name"));
			desc.set_weight(e.font_weight);
			desc.set_variant(e.font_variant);
			desc.set_size(e.font_size * Pango.SCALE);
			((Clutter.Text)contents).font_name = desc.to_string();
			((Clutter.Text)contents).set_line_alignment(e.text_align);
			
			add_actor(contents);
			contents.width = e.width;
			contents.height = e.height;
			contents.x = e.x;
			contents.y = e.y;
		}
	}
}

