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
	public class ImageActor : Actor
	{
		public ImageActor(Element e)
		{
			base(e);
			
			try
			{
				contents = new Clutter.Texture.from_file(e.parent.parent.path + e.data.get_str("filename"));
			}
			catch (GLib.Error e)
			{
				stdout.printf("Error loading ImageActor: %s", e.message);
			}
			finally
			{
				add_actor(contents);
				contents.width = e.width;
				contents.height = e.height;
				contents.x = e.x;
				contents.y = e.y;
			}
		}
	}
}
