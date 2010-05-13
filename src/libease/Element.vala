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
	/**
	 * An object on a {@link Slide}
	 *
	 * While there are several subclasses of {@link Actor} for different types
	 * of presentation objects, there is a single Element class. The Element
	 * class uses an {@link ElementMap} to store data. The "type" key
	 * specifies the type of Element ("text", "image", "video", etc.)
	 * 
	 * For accessing data stored in the {@link ElementMap}, Element provides
	 * several convenience properties. Many of these are specific to a single
	 * type of Element, such as the font_name property for text elements.
	 * Accessing these properties in the wrong type of Element will cause
	 * bad things to happen, including the heat death of the universe.
	 */
	public class Element : GLib.Object
	{
		public Slide parent { get; set; }

		public ElementMap data = new ElementMap();
		
		/**
		 * Create a new element.
		 *
		 * @param owner The slide that this Element belongs to.
		 */
		public Element(Slide owner)
		{
			parent = owner;
		}
		
		/**
		 * Create a document from a file that already exists.
		 * 
		 * Currently, this simply invokes to_xml() on the Element's
		 * {@link ElementMap}. Although the {@link ElementMap} is a public
		 * field, this could change in the future, so always use to_xml()
		 * on the Element itself.
		 */
		public string to_xml()
		{
			return data.to_xml();
		}
		
		/**
		 * Creates HTML markup for this Element.
		 * 
		 * The <div> tag for this Element is appended to the "HTML" parameter.
		 * This should be inside a <div> tag for the Element's {@link Slide}.
		 *
		 * @param html The HTML string in its current state.
		 * @param exporter The {@link HTMLExporter}, for the path and progress.
		 * @param amount The amount progress should increase by when done.
		 */
		public void to_html(ref string html,
		                    HTMLExporter exporter,
		                    double amount)
		{
			switch (data.get_str("element_type"))
			{
				case "image":
					// open the img tag
					html += "<img class=\"image element\" ";
					
					// set the image's style
					html += "style=\"";
					html += "left:" + data.get_str("x") + "px;";
					html += " top:" + data.get_str("y") + "px;";
					html += " width:" + data.get_str("width") + "px;";
					html += " height:" + data.get_str("height") + "px;";
					html += " position: absolute;\" ";
					
					// add the image
					html += "src=\"" + exporter.path + " " +
					        data.get_str("filename") + "\" alt=\"Image\" />";
					
					// copy the image file
					exporter.copy_file(data.get_str("filename"),
					                   parent.parent.path);
					
					break;
					
				case "text":
					// open the tag
					html += "<div class=\"text element\" ";
					
					// set the size and position of the element
					html += "style=\"";
					html += "left:" + data.get_str("x") + "px;";
					html += " top:" + data.get_str("y") + "px;";
					html += " width:" + data.get_str("width") + "px;";
					html += " height:" + data.get_str("height") + "px;";
					html += " position: absolute;";
					
					// set the text-specific properties of the element
					html += " color:" + data.get_str("color").substring(0, 7) +
					        ";";
					html += " font-family:" + data.get_str("font_name") + ";";
					html += " font-size:" + data.get_str("font_size") + "pt;\"";
					
					// write the actual content
					html += ">" + data.get_str("text") + "</div>";
					
					break;
					
				case "video":
					break;
			}
			
			// advance the progress bar
			exporter.add_progress(amount);
		}

		// convenience properties

		// base element
		public string ease_name
		{
			set
			{
				data.set_str("ease_name", value);
			}
		}
		
		public string element_type
		{
			set
			{
				data.set_str("element_type", value);
			}
		}
		
		/**
		 * The X position of this Element.
		 */
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
		public string text
		{
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
		
		public string font_name
		{
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
				switch (data.get_str("align"))
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
