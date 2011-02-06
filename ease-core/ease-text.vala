/*  Ease, a GTK presentation application
    Copyright (C) 2010-2011 individual contributors (see AUTHORS)

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
 * Controls a set of PangoLayouts to render rich text to Cairo contexts and Ease
 * {@link TextActors}. Replaces the previous use of ClutterText, which only
 * supported a single font, font size, font style, font weight, and color for a
 * {@link TextElement}.
 */
public class Ease.Text : GLib.Object
{
	/**
	 * The layout, which controls the text and formatting.
	 */
	internal Gee.LinkedList<Layout> layouts;
	
	/**
	 * The context, which the layout requires.
	 */
	private Pango.Context context;
	
	/**
	 * The width of the text layout.
	 */
	public int width { get; set; default = 640; }
	
	/**
	 * The height of the text layout. Text after this height will be ellipsized.
	 */
	public int height { get; set; default = 480; }
	
	/**
	 * The size of the Text as a two item array. Arrays not of length 2 will
	 * be ignored.
	 */
	public int[] size
	{
		owned get { return { width, height }; }
		set
		{
			if (value.length != 2)
			{
				critical("Text size must be a two item array, not %i",
				         value.length);
				return;
			}
			width = value[0];
			height = value[1];
		}
	}
	
	construct
	{
		// create layout set
		layouts = new Gee.LinkedList<Layout>();
		
		// create the first layout
		layouts.add(new Layout());
		
		// set layout properties
		layouts.first().layout.set_ellipsize(Pango.EllipsizeMode.END);
	}
	
	/**
	 * Creates a Text with a starting string and typeface.
	 *
	 * @param text The string to populate the text with.
	 * @param font_description The typeface to use for the starting string.
	 */
	public Text.with_text(string text, Pango.FontDescription font_description)
	{
		layouts.first().layout.set_text(text, (int)text.length);
		layouts.first().layout.set_font_description(font_description);
	}
	
	/**
	 * Advances the cursor by a specified number of characters. If the cursor
	 * cannot be moved forward, it will not be moved.
	 *
	 * @param index The index of the cursor, this value is set on out.
	 * @param layout_index The layout index, this value is set on out.
	 * @param chars The number of characters to advance.
	 */
	public void advance_cursor(ref int index, ref int layout_index, uint chars)
	{
		
	}
	
	/**
	 * Moves the the cursor back by a specified number of characters. If the
	 * cursor cannot move back, it will not be moved.
	 *
	 * @param index The index of the cursor, this value is set on out.
	 * @param layout_index The layout index, this value is set on out.
	 * @param chars The number of characters to advance.
	 */
	public void retreat_cursor(ref int index, ref int layout_index, uint chars)
	{
		
	}
	
	/**
	 * Iterates over each {@link Layout} in a text object.
	 *
	 * @param function The function to call for each iteration. Returning false
	 * will break the iteration.
	 */
	public void @foreach(TextForeachFunc function)
	{
		foreach (var layout in layouts)
		{
			if (!function(layout)) return;
		}
	}
	
	/**
	 * Called for each iteration of {@link foreach}. Returning false will break
	 * the iteration.
	 */
	public delegate bool TextForeachFunc(Layout layout);
	
	/**
	 * Renders the Text to a Cairo Context.
	 *
	 * @param cr The context to render to.
	 * @param use_default If the text is empty, the default string will be
	 * rendered instead of an empty string.
	 */
	public void render(Cairo.Context cr, bool use_default)
	{
		int y = 0;
		cr.save();
		
		// render each layout, if it's within the bounds of the rectangle
		@foreach((layout) => {
			// render the layout
			layout.render(cr, use_default);
			
			// translate for the next render
			cr.translate(0, layout.height_px);
			
			// stop once we've rendered all visible layouts
			y += layout.height_px;
			return y < height;
		});
		
		cr.restore();
	}
	
	/**
	 * Adds a paragraph to the layout.
	 */
	public void add_layout()
	{
		// create the first layout
		var layout = new Layout();
		
		// set layout properties
		layouts.first().layout.set_ellipsize(Pango.EllipsizeMode.END);
		
		// add layout
		layouts.insert(layouts.size, layout);
	}
	
	/**
	 * Inserts a string at a given index.
	 */
	public void insert(string text, int index, int layout_index)
	{
		var layout = layouts.get(layout_index);
		string result, current = layout.text;
		
		// string bounds checking
		if (layout_index > current.length || layout_index < 0)
		{
			critical("Tried to insert %s at index %l to layout with length %i",
			         text, index, current.length);
		}
		
		// figure out where to insert the text, the start and end are simple
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
		
		// set the new text back into the layout
		layout.text = result;
	}
	
	/**
	 * Deletes the character as a given index.
	 */
	public void @delete(int index, int layout_index)
	{
		debug("Delete at %i %i", layout_index, index);
		
		// get the layout
		var layout = layouts.get(layout_index);
		
		// get current string
		var current = layout.text;
		
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
		layout.text = str;
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
		while (layouts.size > 1) layouts.remove_at(1);
		
		layouts.first().text = text;
		if (font_description != null)
		{
			layouts.first().layout.set_font_description(font_description);
		}
	}
	
	/**
	 * Adds an attribute.
	 *
	 * @param attr The attribute to add.
	 */
	public void add_attr(Pango.Attribute attr, int layout_index)
	{
		layouts.get(layout_index).attrs.insert(attr.copy());
	}
	
	/**
	 * Converts from an index within a PangoLayout to the onscreen position
	 * corresponding to the grapheme at that index, which is represented as
	 * rectangle. Note that pos->x is always the leading edge of the grapheme
	 * and pos->x + pos->width the trailing edge of the grapheme. If the
	 * directionality of the grapheme is right-to-left, then pos->width will be
	 * negative.
	 *
	 * The implementation of this function in Text checks across multiple
	 * layouts (as indicated by the second index parameter) for the result.
	 *
	 * @param index The character index.
	 * @param layout_index The layout index.
	 */
	public Pango.Rectangle index_to_pos(int index, int layout_index)
	{
		Pango.Rectangle pos = Pango.Rectangle();
		int i = 0, y = 0;
		@foreach((layout) => {
			if (i < index)
			{
				y += layout.height_px;
				return true;
			}
			else
			{
				layout.layout.index_to_pos(index, out pos);
				pos.y += y * Pango.SCALE;
				return false;
			}
		});
		
		return pos;
	}
	
	/**
	 * Converts from X and Y position within a layout to the byte index to the
	 * character at that logical position. If the Y position is not inside the
	 * layout, the closest position is chosen (the position will be clamped
	 * inside the layout). If the X position is not within the layout, then the
	 * start or the end of the line is chosen as described for
	 * pango_layout_x_to_index(). If either the X or Y positions were not inside
	 * the layout, then the function returns false; on an exact hit, it returns
	 * true.
	 *
	 * @param x The x position, in pixels.
	 * @param y The y position, in pixels.
	 * @param index A return value for the cursor index.
	 * @param layout_index A return value for the layout index.
	 */
	public bool xy_to_index(int x, int y, ref int index, ref int layout_index)
	{
		// clamp the x position
		if (x > width) x = width;
		if (x < 0) x = 0;
		
		// clamp the y position
		if (y > height) y = height;
		if (y < 0) y = 0;
		
		// convert to pango units
		width *= Pango.SCALE;
		height *= Pango.SCALE;
		
		// find the indices
		layout_index = 0;
		foreach (var layout in layouts)
		{
			if (y > layout.height_px)
			{
				y -= layout.height_px;
				layout_index++;
			}
			else
			{
				int trailing = 0;
				layout.layout.xy_to_index(x, y, out index, out trailing);
				index += trailing;
				break;
			}
		}
		
		return true;
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
