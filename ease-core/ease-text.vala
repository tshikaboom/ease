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
 * A string with various types of Pango formatting applied 
 */
public class Ease.Text : GLib.Object
{
	private Pango.Layout layout;
	private Pango.Context context;
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
	
	public Text.with_text(string text, Pango.FontDescription font_description)
	{
		layout.set_text(text, (int)text.length);
		layout.set_font_description(font_description);
	}
	
	public void render(Cairo.Context cr, int width, int height)
	{
		layout.set_width(width * Pango.SCALE);
		layout.set_height(height * Pango.SCALE);
		Pango.cairo_show_layout(cr, layout);
	}
}
