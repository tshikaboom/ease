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
 * Exports {@link Slide}s to PDF files with Cairo.
 */
public static class Ease.PDFExporter : Object
{
	/**
	 * Exports a {@link Document} as a PDF.
	 *
	 * @param document The {@link Document} to export.
	 * @param win The window that dialogs should be modal for.
	 */
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
				s.cairo_render(context);
				context.show_page();
			}
		
			surface.flush();
			surface.finish();
		}
		catch (Error e)
		{
			error_dialog(_("Error Exporting to PDF"), e.message);
		}
	}
}

