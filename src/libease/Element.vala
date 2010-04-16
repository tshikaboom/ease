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
	public class Element : GLib.Object
	{
		public Slide parent { get; set; }

		public ElementMap data = new ElementMap();
		
		public Element(Slide owner)
		{
			parent = owner;
		}
		
		public virtual void print_representation()
		{
			stdout.printf("\t\t\t\tease_name: %s\n", ease_name);
			stdout.printf("\t\t\t\t        x: %f\n", x);
			stdout.printf("\t\t\t\t        y: %f\n", y);
			stdout.printf("\t\t\t\t    width: %f\n", width);
			stdout.printf("\t\t\t\t   height: %f\n", height);
		}

		public string to_xml()
		{
			return data.to_xml();
		}
		
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

		// convenience properties

		// base element
		public string ease_name
		{
			get
			{
				return data.get_str("ease_name").to_string();
			}
			set
			{
				data.set_str("ease_name", value);
			}
		}
		
		public string element_type
		{
			get
			{
				return data.get_str("element_type").to_string();
			}
			set
			{
				data.set_str("element_type", value);
			}
		}
		
		public float x
		{
			get
			{
				return (float)(data.get_str("x").to_double());
			}
			set
			{
				data.set_str("x", @"$value");
			}
		}
		
		public float y
		{
			get
			{
				return (float)(data.get_str("y").to_double());
			}
			set
			{
				data.set_str("y", @"$value");
			}
		}
		
		public float width
		{
			get
			{
				return (float)(data.get_str("width").to_double());
			}
			set
			{
				data.set_str("width", @"$value");
			}
		}
		
		public float height
		{
			get
			{
				return (float)(data.get_str("height").to_double());
			}
			set
			{
				data.set_str("height", @"$value");
			}
		}

		// text elements
		public weak string text
		{
			get
			{
				return data.get_str("text").to_string();
			}
			set
			{
				data.set_str("text", value);
			}
		}
		
		public Clutter.Color color
		{
			get
			{
				Clutter.Color c = Clutter.Color();
				c.from_string(data.get_str("color"));
				return c;
			}		
			set
			{
				data.set_str("color", value.to_string());
			}
		}
		
		public weak string font_name
		{
			get
			{
				return data.get_str("font_name").to_string();
			}
			set
			{
				data.set_str("font_name", value);
			}
		}
		
		public Pango.Style font_style
		{
			get
			{
				switch (data.get_str("font_style"))
				{
					case "Oblique":
						return Pango.Style.OBLIQUE;
					case "Italic":
						return Pango.Style.ITALIC;
					default:
						return Pango.Style.NORMAL;
				}
			}
			set
			{
				switch (value)
				{
					case Pango.Style.OBLIQUE:
						data.set_str("font_style", "Oblique");
						break;
					case Pango.Style.ITALIC:
						data.set_str("font_style", "Italic");
						break;
					case Pango.Style.NORMAL:
						data.set_str("font_style", "Normal");
						break;
				}
			}
		}
		
		public Pango.Variant font_variant
		{
			get
			{
				return data.get_str("font_variant") == "Normal"
				     ? Pango.Variant.NORMAL
				     : Pango.Variant.SMALL_CAPS;
			}
			set
			{
				data.set_str("font_name",
				             value == Pango.Variant.NORMAL ?
				                      "Normal" : "Small Caps");
			}
		}
		
		public Pango.Weight font_weight
		{
			get
			{
				var str = "font_name";
				return (Pango.Weight)(data.get_str(str).to_int());
			}
			set
			{
				data.set_str("font_weight", ((int)value).to_string());
			}
		}
		
		public Pango.Alignment text_align
		{
			get
			{
				switch (data.get_str("font_style"))
				{
					case "right":
						return Pango.Alignment.RIGHT;
					case "center":
						return Pango.Alignment.CENTER;
					default:
						return Pango.Alignment.LEFT;
				}
			}
			set
			{
				switch (value)
				{
					case Pango.Alignment.RIGHT:
						data.set_str("font_style", "right");
						break;
					case Pango.Alignment.CENTER:
						data.set_str("font_style", "center");
						break;
					case Pango.Alignment.LEFT:
						data.set_str("font_style", "left");
						break;
				}
			}
		}
		
		public int font_size
		{
			get
			{
				return data.get_str("font_size").to_int();
			}
			set
			{
				data.set_str("font_size", @"$value");
			}
		}

		// image elements
		public string filename 
		{
			get
			{
				return data.get_str("filename").to_string();
			}
			set
			{
				data.set_str("filename", value);
			}
		}
		
		public float scale_x
		{
			get
			{
				return (float)(data.get_str("scale_x").to_double());
			}
			set
			{
				data.set_str("scale_x", @"$value");
			}
		}
		
		public float scale_y
		{
			get
			{
				return (float)(data.get_str("scale_y").to_double());
			}
			set
			{
				data.set_str("scale_y", @"$value");
			}
		}
	}
}
