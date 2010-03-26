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
	class EditableText : EditableElement
	{
		private Clutter.Text text;
		
		public EditableText(TextElement e, EditorEmbed em)
		{
			element = e;
			
			// create and format the text actor
			text = new Clutter.Text.full(e.font_name + " " + e.font_size.to_string(),
			                             e.text,
			                             e.color);
			text.line_wrap = true;
			text.line_wrap_mode = Pango.WrapMode.WORD_CHAR;
			this.x = element.x;
			this.y = element.y;
			text.width = element.width;
			text.height = element.height;
			
			this.add_actor(text);
			this.init(em);
		}
		
		public override void set_dimensions(float w, float h, float x, float y)
		{
			text.width = w;
			text.height = h;
			base.set_dimensions(w, h, x, y);
		}
	}
}
