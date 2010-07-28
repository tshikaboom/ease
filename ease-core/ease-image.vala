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

public class Ease.Image : GLib.Object
{
	/**
	 * The background image, if this element uses an image for a background.
	 *
	 * To use this property, {@link background_type} must also be set to
	 * {@link BackgroundType.IMAGE}.
	 */
	public string filename { get; set; }
	
	/**
	 * The original path to the background image. This path is used in the UI.
	 */
	public string source { get; set; }
	
	/**
	 * Sets up a CairoContext to render this image.
	 *
	 * @param cr The context to set up.
	 * @param width The width of the rendering.
	 * @param height The height of the rendering.
	 * @param path The base path to any possible media files.
	 */
	public void set_cairo(Cairo.Context cr, int width, int height, string path)
	{
		try
		{
			string full = Path.build_filename(path, filename);
			var pixbuf = new Gdk.Pixbuf.from_file_at_scale(full,
	    	                                               width,
	    	                                               height,
	    	                                               false);
			Gdk.cairo_set_source_pixbuf(cr, pixbuf, 0, 0);
		}
		catch (Error e)
		{
			critical("Error rendering image background: %s", e.message);
		}
	}
}
