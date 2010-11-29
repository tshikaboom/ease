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
 * Controls a PangoLayout to render rich text to Cairo contexts and Ease
 * {@link TextActors}. Replaces the previous use of ClutterText, which only
 * supported a single font, font size, font style, font weight, and color for a
 * {@link TextElement}.
 */
public class Ease.Text : GLib.Object
{
	private const string DEFAULT_TEXT = _("Double click to edit.");
	
	/**
	 * The layout, which controls the text and formatting.
	 */
	internal Pango.Layout layout;
	
	/**
	 * The context, which the layout requires.
	 */
	private Pango.Context context;
	
	/**
	 * The layout's attributes, which control text formatting.
	 */
	private Pango.AttrList attrs;
	
	construct
	{
		// create context and layout
		context = Gdk.pango_context_get_for_screen(Gdk.Screen.get_default());
		layout = new Pango.Layout(context);
		
		// set layout properties
		layout.set_ellipsize(Pango.EllipsizeMode.END);
		
		// create attribute list
		attrs = new Pango.AttrList();
		layout.set_attributes(attrs);
	}
	
	/**
	 * Creates a Text with a starting string and typeface.
	 *
	 * @param text The string to populate the text with.
	 * @param font_description The typeface to use for the starting string.
	 */
	public Text.with_text(string text, Pango.FontDescription font_description)
	{
		layout.set_text(text, (int)text.length);
		layout.set_font_description(font_description);
	}
	
	/**
	 * Renders the Text to a Cairo Context.
	 *
	 * @param cr The context to render to.
	 * @param use_default If the text is empty, the default string will be
	 * rendered instead of an empty string.
	 * @param width The width to render at.
	 * @param height The height to render at.
	 */
	public void render(Cairo.Context cr, bool use_default,
	                   int width, int height)
	{
		// display default text if there is no text in the element
		string text = layout.get_text();
		if (text.length == 0 && use_default)
		{
			layout.set_text(DEFAULT_TEXT, (int)DEFAULT_TEXT.length);
		}
		
		// set size and render
		layout.set_width(width * Pango.SCALE);
		layout.set_height(height * Pango.SCALE);
		Pango.cairo_show_layout(cr, layout);
		
		// restore empty text if necessary
		layout.set_text(text, (int)text.length);
	}
	
	/**
	 * Inserts a string at a given index.
	 */
	public void insert(string text, int index)
	{
		debug("Insert at %i", index);
		string result, current = layout.get_text();
		if (index == 0)
		{
			result = text + current;
		}
		else if (index == current.length)
		{
			result = current + text;
		}
		else
		{
			result = current.substring(0, index) + text +
			         current.substring(index, current.length - index);
		}
		
		layout.set_text(result, (int)result.length);
	}
	
	/**
	 * Deletes the character as a given index.
	 */
	public void @delete(int index)
	{
		debug("Delete at %i", index);
		
		// get current string
		var current = layout.get_text();
		
		// don't do bad things
		if (index >= current.length)
		{
			warning("Trying to delete past the end of a string");
			return;
		}
		if (index < 0)
		{
			warning("Trying to delete past the start of a string");
			return;
		}
		
		// delete the character
		var str = current.substring(0, index) +
		          current.substring(index + 1, current.length - index - 1);
		layout.set_text(str, (int)str.length);
	}
	
	/**
	 * Clears and sets the text, optionally changing the base font description
	 * as well.
	 *
	 * @param text The string to populate the text with.
	 * @param font_description The typeface to use for the string, or null to
	 * keep the current typeface.
	 */
	public void clear_set(string text, Pango.FontDescription? font_description)
	{
		layout.set_text(text, (int)text.length);
		if (font_description != null)
		{
			layout.set_font_description(font_description);
		}
	}
	
	/**
	 * Creates a PangoStyle from a string.
	 */
	public static Pango.Style style_from_string(string str)
	{
		switch (str)
		{
			case "oblique":
				return Pango.Style.OBLIQUE;
				break;
			case "italic":
				return Pango.Style.ITALIC;
				break;
			default:
				return Pango.Style.NORMAL;
				break;
		}
	}
	
	/**
	 * Transforms a PangoStyle to a string.
	 */
	public static string style_to_string(Pango.Style style)
	{
		switch (style)
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
	
	/**
	 * Creates a PangoVariant from a string.
	 */
	public static Pango.Variant variant_from_string(string str)
	{
		return str == "normal"
		     ? Pango.Variant.NORMAL
		     : Pango.Variant.SMALL_CAPS;
	}
	
	/**
	 * Transforms a PangoVariant to a string.
	 */
	public static string variant_to_string(Pango.Variant variant)
	{
		return variant == Pango.Variant.NORMAL ? "Normal" : "Small Caps";
	}
	
	public static Pango.Weight weight_from_string(string str)
	{
		return (Pango.Weight)(str.to_int());
	}
	
	/**
	 * Transforms a PangoWeight to a string.
	 */
	public static string weight_to_string(Pango.Weight weight)
	{
		return ((int)weight).to_string();
	}
	
	/**
	 * Creates a PangoAlignment from a string.
	 */
	public static Pango.Alignment alignment_from_string(string str)
	{
		switch (str)
		{
			case "right":
			case "gtk-justify-right":
				return Pango.Alignment.RIGHT;
			case "center":
			case "gtk-justify-center":
				return Pango.Alignment.CENTER;
			case "left":
			case "gtk-justify-left":
				return Pango.Alignment.LEFT;
			default:
				critical("Illegal alignment: %s", str);
				return Pango.Alignment.LEFT;
		}
	}
	
	/**
	 * Transforms a PangoAlignment to a string.
	 */
	public static string alignment_to_string(Pango.Alignment alignment)
	{
		switch (alignment)
		{
			case Pango.Alignment.RIGHT:
				return "right";
			case Pango.Alignment.CENTER:
				return "center";
			default:
				return "left";
		}
	}
}
