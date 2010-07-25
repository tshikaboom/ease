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
	 * Creates a new TextElement.
	 */
	public TextElement() { }
	
	/**
	 * Create a TextElement from a JsonObject
	 */
	public TextElement.from_json(Json.Object obj)
	{
		base.from_json(obj);
		
		text = obj.get_string_member(Theme.TEXT_TEXT);
		color = new Color.from_string(obj.get_string_member(Theme.TEXT_COLOR));
		text_font = obj.get_string_member(Theme.TEXT_FONT);
		text_style_from_string(obj.get_string_member(Theme.TEXT_STYLE));
		text_variant_from_string(obj.get_string_member(Theme.TEXT_VARIANT));
		text_weight_from_string(obj.get_string_member(Theme.TEXT_WEIGHT));
		text_align_from_string(obj.get_string_member(Theme.TEXT_ALIGN));
		text_size_from_string(obj.get_string_member(Theme.TEXT_SIZE));
	}
	
	public override Json.Object to_json()
	{
		var obj = base.to_json();
		
		obj.set_string_member(Theme.TEXT_COLOR, color.to_string());
		obj.set_string_member(Theme.TEXT_TEXT, text);
		obj.set_string_member(Theme.TEXT_FONT, text_font);
		obj.set_string_member(Theme.TEXT_STYLE, text_style_to_string());
		obj.set_string_member(Theme.TEXT_VARIANT, text_variant_to_string());
		obj.set_string_member(Theme.TEXT_WEIGHT, text_weight_to_string());
		obj.set_string_member(Theme.TEXT_ALIGN, text_align_to_string());
		obj.set_string_member(Theme.TEXT_SIZE, text_size_to_string());
		
		return obj;
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
		color = new Color.from_clutter(c);
		return true;
	}
	
	/**
	 * This method returns the color of the TextElement.
	 */
	public override Clutter.Color? get_color()
	{
		return color.clutter;
	}


	protected override void write_html(ref string html, HTMLExporter exporter)
	{
		// open the tag
		html += "<div class=\"text element\" ";
		
		// set the size and position of the element
		html += "style=\"";
		html += "left:" + x.to_string() + "px;";
		html += " top:" + y.to_string() + "px;";
		html += " width:" + width.to_string() + "px;";
		html += " height:" + width.to_string() + "px;";
		html += " position: absolute;";
		
		// set the text-specific properties of the element
		html += " color:" + 
		        @"rgb($(color.red),$(color.green),$(color.blue));";
		        
		html += " font-family:'" + text_font + "', sans-serif;";
		        
		html += " font-size:" + text_size_to_string() + "pt;";
		
		html += " font-weight:" + text_weight_to_string() + ";";
		html += " font-style:" + text_style_to_string().down() +
		        ";";
		        
		html += " text-align:" + text_align_to_string() + ";\"";
		
		// write the actual content
		html += ">" + text.replace("\n", "<br />") +
		        "</div>";
	}

	/**
	 * Renders a text Element with Cairo.
	 */
	public override void cairo_render(Cairo.Context context) throws Error
	{	
		// create the layout
		var layout = Pango.cairo_create_layout(context);
		layout.set_text(text, (int)text.length);
		layout.set_width((int)(width * Pango.SCALE));
		layout.set_height((int)(height * Pango.SCALE));
		layout.set_font_description(font_description);
		layout.set_alignment(text_align);
		
		// render
		context.save();
		
		color.set_cairo(context);
		
		Pango.cairo_update_layout(context, layout);
		context.move_to((int)x, (int)y);
		
		Pango.cairo_show_layout(context, layout);
		context.restore();
	}
	
	/**
	 * The text value of this Element.
	 */
	public string text { get; set; }
	
	/**
	 * The color of the text.
	 */
	public Color color { get; set; }
	
	/**
	 * The name of the text's font family.
	 */
	public string text_font
	{
		get { return text_font_priv; }
		set
		{
			text_font_priv = value;
			if (!freeze) notify_property("font-description");
		}
	}
	private string text_font_priv;
	
	/**
	 * The PangoStyle for this Element.
	 */
	public Pango.Style text_style
	{
		get { return text_style_priv; }
		set
		{
			text_style_priv = value;
			if (!freeze) notify_property("font-description");
		}
	}
	private Pango.Style text_style_priv;
	
	public string text_style_to_string()
	{
		switch (text_style)
		{
			case Pango.Style.OBLIQUE:
				return "oblique";
			case Pango.Style.ITALIC:
				return "italic";
			case Pango.Style.NORMAL:
				return "normal";
			default:
				critical("Invalid text style");
				return "normal";
		}
	}
	
	public void text_style_from_string(string str)
	{
		switch (str)
		{
			case "oblique":
				text_style = Pango.Style.OBLIQUE;
				break;
			case "italic":
				text_style = Pango.Style.ITALIC;
				break;
			default:
				text_style = Pango.Style.NORMAL;
				break;
		}
	}
	
	/**
	 * The PangoVariant for this Element.
	 */
	public Pango.Variant text_variant
	{
		get { return text_variant_priv; }
		set
		{
			text_variant_priv = value;
			if (!freeze) notify_property("font-description");
		}
	}
	private Pango.Variant text_variant_priv;
	
	public void text_variant_from_string(string str)
	{
		text_variant = str == "normal" ?
		                      Pango.Variant.NORMAL : Pango.Variant.SMALL_CAPS;
	}
	
	public string text_variant_to_string()
	{
		return text_variant == Pango.Variant.NORMAL ? "Normal" : "Small Caps";
	}
	
	/**
	 * The font's weight.
	 */
	public int text_weight
	{
		get { return text_weight_priv; }
		set
		{
			text_weight_priv = value;
			if (!freeze) notify_property("font-description");
		}
	}
	private int text_weight_priv;
	
	
	public void text_weight_from_string(string str)
	{
		text_weight = (Pango.Weight)(str.to_int());
	}
	
	public string text_weight_to_string()
	{
		return ((int)text_weight).to_string();
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
			desc.set_family(text_font);
			desc.set_style(text_style);
			desc.set_weight((Pango.Weight)text_weight);
			desc.set_variant(text_variant);
			desc.set_size(text_size * Pango.SCALE);
			
			return desc;
		}
		set
		{
			freeze = true;
			text_font = value.get_family();
			text_style = value.get_style();
			text_weight = (int)value.get_weight();
			text_variant = value.get_variant();
			text_size = value.get_size() / Pango.SCALE;
			freeze = false;
		}
	}
	
	/**
	 * The alignment of the text.
	 */
	public Pango.Alignment text_align { get; set; }
	
	public void text_align_from_string(string str)
	{
		switch (str)
		{
			case "right":
				text_align = Pango.Alignment.RIGHT;
				break;
			case "center":
				text_align = Pango.Alignment.CENTER;
				break;
			case "left":
				text_align = Pango.Alignment.LEFT;
				break;
			default:
				critical("Illegal alignment: %s", str);
				text_align = Pango.Alignment.LEFT;
				break;
		}
	}
	
	public string text_align_to_string()
	{
		switch (text_align)
		{
			case Pango.Alignment.RIGHT:
				return "right";
			case Pango.Alignment.CENTER:
				return "center";
			default:
				return "left";
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
		get { return text_size_priv; }
		set
		{
			text_size_priv = value;
			if (!freeze) notify_property("font-description");
		}
	}
	private int text_size_priv;

	public void text_size_from_string(string str)
	{
		text_size = str.to_int();
	}
	
	public string text_size_to_string()
	{
		return text_size.to_string();
	}
}
