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
 * An {@link Element} subclass for displaying text. Linked with {@link TextActor}.
 */
public class Ease.TextElement : Element
{
	private bool freeze = false;
	
	/**
	 * Create a new element, with an empty {@link ElementMap}.
	 */
	public TextElement()
	{
		data = new ElementMap();
	}
	
	/**
	 * Creates a completely empty TextElement, without an {@link ElementMap}.
	 */
	public TextElement.empty() {}	

	public override Element copy()
	{
		var element = new TextElement.empty();
		element.parent = parent;
		element.data = data.copy();
		
		return element;
	}
	
	public override Actor actor(ActorContext c)
	{
		return new TextActor(this, c);
	}
	
	/**
	 * This method sets the color of this TextElement, then returns "true".
	 *
	 * @param c The color to set the element to.
	 */
	public override bool set_color(Clutter.Color c)
	{
		color = c;
		return true;
	}
	
	/**
	 * This method returns the color of the TextElement.
	 */
	public override Clutter.Color? get_color()
	{
		return color;
	}


	protected override void write_html(ref string html, HTMLExporter exporter)
	{
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
		        
		html += " font-family:'" + data.get(Theme.TEXT_FONT) +
		        "', sans-serif;";
		        
		html += " font-size:" + data.get(Theme.TEXT_SIZE) + "pt;";
		
		html += " font-weight:" + data.get(Theme.TEXT_WEIGHT) + ";";
		html += " font-style:" + data.get(Theme.TEXT_STYLE).down() +
		        ";";
		        
		html += " text-align:" + data.get(Theme.TEXT_ALIGN) + ";\"";
		
		// write the actual content
		html += ">" + data.get("text").replace("\n", "<br />") +
		        "</div>";
	}

	/**
	 * Renders a text Element with Cairo.
	 */
	public override void cairo_render(Cairo.Context context) throws Error
	{	
		// create the layout
		var layout = Pango.cairo_create_layout(context);
		layout.set_text(data.get("text"), (int)data.get("text").length);
		layout.set_width((int)(width * Pango.SCALE));
		layout.set_height((int)(height * Pango.SCALE));
		layout.set_font_description(font_description);
		layout.set_alignment(text_align);
		
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
	
	/**
	 * The text value of this Element.
	 */
	public string text
	{
		owned get { return data.get("text"); }
		set	{ data.set("text", value); }
	}
	
	/**
	 * The color of the text.
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
	 * The name of the text's font family.
	 */
	public string text_font
	{
		owned get { return data.get(Theme.TEXT_FONT); }
		set
		{
			data.set(Theme.TEXT_FONT, value);
			if (!freeze) notify_property("font-description");
		}
	}
	
	/**
	 * The PangoStyle for this Element.
	 */
	public Pango.Style text_style
	{
		get
		{
			switch (data.get(Theme.TEXT_STYLE))
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
					data.set(Theme.TEXT_STYLE, "Oblique");
					break;
				case Pango.Style.ITALIC:
					data.set(Theme.TEXT_STYLE, "Italic");
					break;
				case Pango.Style.NORMAL:
					data.set(Theme.TEXT_STYLE, "Normal");
					break;
			}
			if (!freeze) notify_property("font-description");
		}
	}
	
	/**
	 * The PangoVariant for this Element.
	 */
	public Pango.Variant text_variant
	{
		get
		{
			return data.get(Theme.TEXT_VARIANT) == "Normal"
			     ? Pango.Variant.NORMAL
			     : Pango.Variant.SMALL_CAPS;
		}
		set
		{
			data.set(Theme.TEXT_VARIANT,
			          value == Pango.Variant.NORMAL ?
			          "Normal" : "Small Caps");
			if (!freeze) notify_property("font-description");
		}
	}
	
	/**
	 * The font's weight.
	 */
	public Pango.Weight text_weight
	{
		get
		{
			return (Pango.Weight)(data.get(Theme.TEXT_WEIGHT).to_int());
		}
		set
		{
			data.set(Theme.TEXT_WEIGHT, ((int)value).to_string());
			if (!freeze) notify_property("font-description");
		}
	}
	
	/**
	 * A full PangoFontDescription for this Element.
	 *
	 * This property creates a new FontDescription when retrieved, and
	 * sets all appropriate properties (text_weight, etc.) when set.
	 */
	public Pango.FontDescription font_description
	{
		owned get
		{
			var desc = new Pango.FontDescription();
			desc.set_family(data.get(Theme.TEXT_FONT));
			desc.set_style(text_style);
			desc.set_weight(text_weight);
			desc.set_variant(text_variant);
			desc.set_size(text_size * Pango.SCALE);
			
			return desc;
		}
		set
		{
			freeze = true;
			data.set(Theme.TEXT_FONT, value.get_family());
			text_style = value.get_style();
			text_weight = value.get_weight();
			text_variant = value.get_variant();
			text_size = value.get_size() / Pango.SCALE;
			freeze = false;
		}
	}
	
	/**
	 * The alignment of the text.
	 */
	public Pango.Alignment text_align
	{
		get
		{
			switch (data.get(Theme.TEXT_ALIGN))
			{
				case "right":
					return Pango.Alignment.RIGHT;
				case "center":
					return Pango.Alignment.CENTER;
				case "left":
					return Pango.Alignment.LEFT;
				default:
					error("Illegal alignment: %s", data.get(Theme.TEXT_ALIGN));
					return Pango.Alignment.LEFT;
			}
		}
		set
		{
			switch (value)
			{
				case Pango.Alignment.RIGHT:
					data.set(Theme.TEXT_ALIGN, "right");
					break;
				case Pango.Alignment.CENTER:
					data.set(Theme.TEXT_ALIGN, "center");
					break;
				case Pango.Alignment.LEFT:
					data.set(Theme.TEXT_ALIGN, "left");
					break;
				default:
					error("Illegal alignment: %s", value.to_string());
					break;
			}
		}
	}
	
	/**
	 * The size of the font.
	 *
	 * This value should be multiplied by Pango.SCALE for rendering, otherwise
	 * the text will be far too small to be visible.
	 */
	public int text_size
	{
		get
		{
			return data.get(Theme.TEXT_SIZE).to_int();
		}
		set
		{
			data.set(Theme.TEXT_SIZE, value.to_string());
			if (!freeze) notify_property("font-description");
		}
	}
}
