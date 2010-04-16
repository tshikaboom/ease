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
	public class ImageElement : Element
	{
		public string filename { get; set; }
		public float scale_x { get; set; }
		public float scale_y { get; set; }
		
		public ImageElement.from_map(Gee.Map<string, string> map, Slide owner)
		{
			base.from_map(map, owner);
			this.element_type = "image";
			this.filename = map.get("filename");
			this.scale_x = (float)map.get("scale_x").to_double();
			this.scale_y = (float)map.get("scale_y").to_double();
		}
		
		public override string to_xml()
		{
			return "\t\t\t<element type=\"image\" " +
			       xml_base() +
			       "filename=\"" + filename + "\" " +
			       "scale_x=\"" + @"$scale_x" + "\" " +
			       "scale_y=\"" + @"$scale_y" + "\" " +
			       "/>\n";
			       
		}
		
		public override Clutter.Actor presentation_actor() throws GLib.Error
		{
			try
			{
				var actor = new Clutter.Texture.from_file(parent.parent.path + filename);
				set_actor_base_properties(actor);
				return actor;
			}
			catch (GLib.Error e)
			{
				throw e;
			}
		}

		public override string get_filename()
		{
			return filename;
		}
	}
}
