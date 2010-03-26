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
	class EditableImage : EditableElement
	{
		private Clutter.Texture texture;
		
		public EditableImage(ImageElement e, EditorEmbed em)
		{
			element = e;
			
			// create and format the texture actor
			texture = new Clutter.Texture.from_file(e.parent.parent.path + e.filename);
			this.x = element.x;
			this.y = element.y;
			texture.width = element.width;
			texture.height = element.height;
			
			this.add_actor(texture);
			this.init(em);
		}
		
		public override void set_dimensions(float w, float h, float x, float y)
		{
			texture.width = w;
			texture.height = h;
			base.set_dimensions(w, h, x, y);
		}
	}
}
