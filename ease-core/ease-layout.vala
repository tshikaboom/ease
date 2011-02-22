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
 * Provides several additions to PangoLayout in a GObject wrapper.
 *
 * If additional functionality is required, in general, it should be added to
 * Layout (or {@link Text}), rather than accessing the PangoLayout member
 * directly, so that Layout appears to be a subclass of PangoLayout (which is
 * not subclassable).
 */
public class Ease.Layout : GLib.Object
{
	/**
	 * Default filler text, which can be rendered if the text is empty.
	 */
	private const string DEFAULT_TEXT = _("Double click to edit.");
	
	/**
	 * The PangoLayout that this EaseLayout is wrapping.
	 */
	public Pango.Layout layout { get; private set; }
	
	/**
	 * The context, which the layout requires.
	 */
	private Pango.Context context;
	
	/**
	 * The text of the PangoLayout.
	 */
	public string text
	{
		get { return layout.get_text(); }
		set { layout.set_text(value, (int)value.length); }
	}
	
	/**
	 * The height of the layout.
	 */
	public int width
	{
		get { return layout.get_width(); }
		set { layout.set_width(value); }
	}
	
	/**
	 * The height of the layout.
	 */
	public int height
	{
		get { return layout.get_height(); }
		set { layout.set_height(value); }
	}
	
	/**
	 * The actual rendered width of the layout, in pixels. This cannot be set.
	 */
	public int width_px
	{
		get
		{
			int width, height;
			layout.get_pixel_size(out width, out height);
			return width;
		}
	}
	
	/**
	 * The actual rendered height of the layout, in pixels. This cannot be set.
	 */
	public int height_px
	{
		get
		{
			int width, height;
			layout.get_pixel_size(out width, out height);
			return height;
		}
	}
	
	/**
	 * The actual rendered size of the layout, in pixels. This cannot be set.
	 */
	public int[] size_px
	{
		owned get
		{
			int width, height;
			layout.get_pixel_size(out width, out height);
			return { width, height };
		}
	}
	
	/**
	 * The length of the layout's text.
	 */
	public int length
	{
		get { return (int)layout.get_text().length; }
	}
	
	/**
	 * The attribute list of the layout. In {@link TextElement}, this is
	 * controlled by a master list of attributes that operates across the
	 * entire set of layouts.
	 */
	public Pango.AttrList attrs
	{
		get { return layout.get_attributes(); }
		set { layout.set_attributes(value); }
	}
	
	construct
	{
		// create context and layout
		context = Gdk.pango_context_get_for_screen(Gdk.Screen.get_default());
		layout = new Pango.Layout(context);
		
		// set layout properties
		layout.set_ellipsize(Pango.EllipsizeMode.END);
		
		// create attribute list
		attrs = new Pango.AttrList();
	}
	
	/**
	 * Renders the layout to a Cairo context.
	 *
	 * @param use_default If the default filler text should be used if the
	 * layout is empty.
	 */
	public void render(Cairo.Context cr, bool use_default)
	{
		// display default text if there is no text in the element
		string text = layout.get_text();
		if (text.length == 0 && use_default)
		{
			layout.set_text(DEFAULT_TEXT, (int)DEFAULT_TEXT.length);
		}
		
		// render
		Pango.cairo_show_layout(cr, layout);
		
		// restore empty text if necessary
		layout.set_text(text, (int)text.length);
	}
	
	/*
	 * Sets the size of the Layout.
	 *
	 * @param width The width.
	 * @param height The height.
	 */
	public void set_size(int width, int height)
	{
		layout.set_width(width);
		layout.set_height(height);
	}
}

