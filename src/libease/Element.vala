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
	public abstract class Element : GLib.Object
	{
		public string ease_name { get; set; }
		public string element_type { get; set; }
		public float x { get; set; }
		public float y { get; set; }
		public float width { get; set; }
		public float height { get; set; }
		public Slide parent { get; set; }
		
		public Element.from_map(Gee.Map<string, string> map, Slide owner)
		{
			this.ease_name = map.get("ease_name");
			this.x = map.get("x").to_int();
			this.y = map.get("y").to_int();
			this.width = map.get("width").to_int();
			this.height = map.get("height").to_int();
			this.parent = owner;
		}
		
		public virtual void print_representation()
		{
			stdout.printf("\t\t\t\tease_name: %s\n", ease_name);
			stdout.printf("\t\t\t\t        x: %f\n", x);
			stdout.printf("\t\t\t\t        y: %f\n", y);
			stdout.printf("\t\t\t\t    width: %f\n", width);
			stdout.printf("\t\t\t\t   height: %f\n", height);
		}
		
		public abstract Clutter.Actor presentation_actor() throws GLib.Error;
		
		public abstract string to_xml();
		
		protected string xml_base()
		{
			return "ease_name=\"" + ease_name + "\" " +
			       "x=\"" + @"$x" + "\" " +
			       "y=\"" + @"$y" + "\" " +
			       "width=\"" + @"$width" + "\" " +
			       "height=\"" + @"$height" + "\" ";
		}
		
		protected void set_actor_base_properties(Clutter.Actor actor)
		{
			actor.x = this.x;
			actor.y = this.y;
			actor.width = this.width;
			actor.height = this.height;
		}

		public virtual string get_filename()
		{
			return "";
		}
	}
}
