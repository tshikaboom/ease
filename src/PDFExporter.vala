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

public static class Ease.PDFExporter : Object
{
	public static void export(Document document, Gtk.Window win)
	{
		string path;
		
		var dialog = new Gtk.FileChooserDialog(_("Export to PDF"),
		                                       win,
		                                       Gtk.FileChooserAction.SAVE,
		                                       "gtk-save",
		                                       Gtk.ResponseType.ACCEPT,
		                                       "gtk-cancel",
		                                       Gtk.ResponseType.CANCEL,
		                                       null);
		
		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			// clean up the file dialog
			path = dialog.get_filename();
			dialog.destroy();
		}
		else
		{
			dialog.destroy();
			return;
		}
		
		try
		{
			// create a PDF surface
			var surface = new Cairo.PdfSurface(path,
			                                   document.width, document.height);
		
			var context = new Cairo.Context(surface);
		
			foreach (var s in document.slides)
			{
				write_slide(s, context);
				context.show_page();
			}
		
			surface.flush();
			surface.finish();
		}
		catch (Error e)
		{
			var error = new Gtk.MessageDialog(null,
			                                  0,
			                                   Gtk.MessageType.ERROR,
			                                   Gtk.ButtonsType.CLOSE,
			                                   _("Error exporting: %s"),
			                                   e.message);
			
			error.title = _("Error Exporting to PDF");
			error.run();
		}
	}
	
	public static void write_slide(Slide s, Cairo.Context context) throws Error
	{
		// write the background color if there is no image
		if (s.background_image == null)
		{
			context.rectangle(0, 0, s.parent.width, s.parent.height);
			context.set_source_rgb(s.background_color.red / 255f,
			                       s.background_color.green / 255f,
			                       s.background_color.blue / 255f);
			context.fill();
		}
		
		// otherwise, write the image
		else
		{
			var pixbuf = new Gdk.Pixbuf.from_file_at_scale(s.background_abs,
			                                               s.parent.width,
			                                               s.parent.height,
			                                               false);
		
			Gdk.cairo_set_source_pixbuf(context, pixbuf, 0, 0);
		
			context.rectangle(0, 0, s.parent.width, s.parent.height);
			context.fill();
		}
		
		foreach (var e in s.elements)
		{
			e.pdf_render(context);
		}
	}
}
