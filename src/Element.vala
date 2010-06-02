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
public class Ease.Element : GLib.Object
{
	/**
	 * The {@link Slide} that this Element is a part of.
	 */
	public Slide parent { get; set; }
	
	/**
	 * The store of information for this Slide. Data can be accessed either
	 * directly though get() and set(), or though the typed convenience
	 * properties that Element provides.
	 */
	public ElementMap data = new ElementMap();
	
	/**
	 * Create a new element.
	 */
	public Element() {}
	
	/**
	 * Create a new element.
	 *
	 * @param owner The slide that this Element belongs to.
	 */
	public Element.with_owner(Slide owner)
	{
		parent = owner;
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
		switch (data.get("element_type"))
		{
			case "image":
				// open the img tag
				html += "<img class=\"image element\" ";
				
				// set the image's style
				html += "style=\"";
				html += "left:" + data.get("x") + "px;";
				html += " top:" + data.get("y") + "px;";
				html += " width:" + data.get("width") + "px;";
				html += " height:" + data.get("height") + "px;";
				html += " position: absolute;\" ";
				
				// add the image
				html += "src=\"" + exporter.path + " " +
				        data.get("filename") + "\" alt=\"Image\" />";
				
				// copy the image file
				exporter.copy_file(data.get("filename"),
				                   parent.parent.path);
				
				break;
				
			case "text":
				// open the tag
				html += "<div class=\"text element\" ";
				
				// set the size and position of the element
				html += "style=\"";
				html += "left:" + data.get("x") + "px;";
				html += " top:" + data.get("y") + "px;";
				html += " width:" + data.get("width") + "px;";
				html += " height:" + data.get("height") + "px;";
				html += " position: absolute;";
				
				// set the text-specific properties of the element
				html += " color:" + 
				        @"rgb($(color.red),$(color.green),$(color.blue));";
				        
				html += " font-family:'" + data.get("font_name") +
				        "', sans-serif;";
				        
				html += " font-size:" + data.get("font_size") + "pt;";
				
				html += " font-weight:" + data.get("font_name").to_int().to_string() +
				        ";";
				html += " font-style:" + data.get("font_style").down() +
				        ";";
				        
				html += " text-align:" + data.get("align") + ";\"";
				
				// write the actual content
				html += ">" + data.get("text").replace("\n", "<br />") +
				        "</div>";
				
				break;
				
			case "video":
				// open the tag
				html += "<video class=\"video element\" ";
				
				// set the video's style
				html += "style=\"";
				html += "left:" + data.get("x") + "px;";
				html += " top:" + data.get("y") + "px;";
				html += " position: absolute;\" ";
				
				// set the video's size
				html += " width=\"" + data.get("width") + "\" ";
				html += " height=\"" + data.get("height") + "\" ";
				
				// set the video's source and controls
				html += "src=\"" + exporter.path + " " +
				        data.get("filename") + "\" " +
				        "controls=\"yes\">" +
				        _("Your browser does not support the video tag") + 
				        "</video>";
				        
				// copy the video file
				exporter.copy_file(data.get("filename"),
				                   parent.parent.path);
				
				break;
		}
		
		// advance the progress bar
		exporter.add_progress(amount);
	}
	
	public void pdf_render(Cairo.Context context) throws Error
	{
		switch (data.get("element_type"))
		{
			case "image":
				pdf_render_image(context);
				break;
			case "text":
				pdf_render_text(context);
				break;
		}
	}
	
	private void pdf_render_image(Cairo.Context context) throws Error
	{
		var filename = parent.parent.path + "/" + data.get("filename");
		
		// load the image
		var pixbuf = new Gdk.Pixbuf.from_file_at_scale(filename,
		                                               (int)width,
		                                               (int)height,
		                                               false);
		
		Gdk.cairo_set_source_pixbuf(context, pixbuf, x, y);
		
		context.rectangle(x, y, width, height);
		context.fill();
	}
	
	private void pdf_render_text(Cairo.Context context) throws Error
	{	
		// create the layout
		var layout = Pango.cairo_create_layout(context);
		layout.set_text(data.get("text"), (int)data.get("text").length);
		layout.set_width((int)(width * Pango.SCALE));
		layout.set_height((int)(height * Pango.SCALE));
		layout.set_font_description(font_description);
		
		// render
		context.save();
		
		context.set_source_rgb(color.red / 255f,
		                       color.green / 255f,
		                       color.blue / 255f);
		
		Pango.cairo_update_layout(context, layout);
		context.move_to((int)x, (int)y);
		
		Pango.cairo_show_layout(context, layout);
		context.restore();
	}

	// convenience properties

	// base element
	
	/**
	 * A unique identifier for this Element.
	 */
	public string ease_name
	{
		owned get { return data.get("ease_name"); }
		set	{ data.set("ease_name", value);	}
	}
	
	/**
	 * The Element's type: currently "text", "image", or "video".
	 */
	public string element_type
	{
		owned get { return data.get("element_type"); }
		set	{ data.set("element_type", value); }
	}
	
	/**
	 * The X position of this Element.
	 */
	public float x
	{
		get
		{
			return (float)(data.get("x").to_double());
		}
		set
		{
			data.set("x", @"$value");
		}
	}
	
	/**
	 * The Y position of this Element.
	 */
	public float y
	{
		get
		{
			return (float)(data.get("y").to_double());
		}
		set
		{
			data.set("y", @"$value");
		}
	}
	
	/**
	 * The width of this Element.
	 */
	public float width
	{
		get
		{
			return (float)(data.get("width").to_double());
		}
		set
		{
			data.set("width", @"$value");
		}
	}
	
	/**
	 * The height of this Element.
	 */
	public float height
	{
		get
		{
			return (float)(data.get("height").to_double());
		}
		set
		{
			data.set("height", @"$value");
		}
	}

	// text elements
	
	/**
	 * The text value of this Element. Only available for "text" Elements.
	 */
	public string text
	{
		owned get { return data.get("text"); }
		set	{ data.set("text", value); }
	}
	
	/**
	 * The color of the text. Only available for "text" Elements.
	 */
	public Clutter.Color color
	{
		get
		{
			return { (uchar)data.get("red").to_int(),
			         (uchar)data.get("green").to_int(),
			         (uchar)data.get("blue").to_int(),
			         255};
		}		
		set
		{
			data.set("red", ((int)value.red).to_string());
			data.set("green", ((int)value.green).to_string());
			data.set("blue", ((int)value.blue).to_string());
		}
	}
	
	/**
	 * The name of the text's font family. Only available for "text" Elements.
	 */
	public string font_name
	{
		set
		{
			data.set("font_name", value);
		}
	}
	
	/**
	 * The PangoStyle for this Element. Only available for "text" Elements.
	 */
	public Pango.Style font_style
	{
		get
		{
			switch (data.get("font_style"))
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
					data.set("font_style", "Oblique");
					break;
				case Pango.Style.ITALIC:
					data.set("font_style", "Italic");
					break;
				case Pango.Style.NORMAL:
					data.set("font_style", "Normal");
					break;
			}
		}
	}
	
	/**
	 * The PangoVariant for this Element. Only available for "text" Elements.
	 */
	public Pango.Variant font_variant
	{
		get
		{
			return data.get("font_variant") == "Normal"
			     ? Pango.Variant.NORMAL
			     : Pango.Variant.SMALL_CAPS;
		}
		set
		{
			data.set("font_name",
			             value == Pango.Variant.NORMAL ?
			                      "Normal" : "Small Caps");
		}
	}
	
	/**
	 * The font's weight. Only available for "text" Elements.
	 */
	public Pango.Weight font_weight
	{
		get
		{
			var str = "font_name";
			return (Pango.Weight)(data.get(str).to_int());
		}
		set
		{
			data.set("font_weight", ((int)value).to_string());
		}
	}
	
	/**
	 * A full PangoFontDescription for this Element.
	 *
	 * This property creates a new FontDescription when retrieved, and
	 * sets all appropriate properties (font_weight, etc.) when set. Only
	 * available for "text" Elements.
	 */
	public Pango.FontDescription font_description
	{
		owned get
		{
			var desc = new Pango.FontDescription();
			desc.set_family(data.get("font_name"));
			desc.set_style(font_style);
			desc.set_weight(font_weight);
			desc.set_variant(font_variant);
			desc.set_size(font_size * Pango.SCALE);
			
			return desc;
		}
		set
		{
			data.set("font_name", value.get_family());
			font_style = value.get_style();
			font_weight = value.get_weight();
			font_variant = value.get_variant();
			font_size = value.get_size() / Pango.SCALE;
		}
	}
	
	/**
	 * The alignment of the text. Only available for "text" Elements.
	 */
	public Pango.Alignment text_align
	{
		get
		{
			switch (data.get("align"))
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
					data.set("font_style", "right");
					break;
				case Pango.Alignment.CENTER:
					data.set("font_style", "center");
					break;
				case Pango.Alignment.LEFT:
					data.set("font_style", "left");
					break;
			}
		}
	}
	
	/**
	 * The size of the font. Only available for "text" Elements.
	 *
	 * This value should be multiplied by Pango.SCALE for rendering, otherwise
	 * the text will be far too small to be visible.
	 */
	public int font_size
	{
		get
		{
			return data.get("font_size").to_int();
		}
		set
		{
			data.set("font_size", @"$value");
		}
	}

	// image and video elements
	
	/**
	 * The path to a media file. Applies to "image" and "video" Elements.
	 */
	public string filename
	{
		owned get { return data.get("filename"); }
		set	{ data.set("filename", value); }
	}
}

