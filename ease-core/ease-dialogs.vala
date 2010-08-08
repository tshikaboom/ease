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
 * Common dialog windows used in Ease.
 */
namespace Ease.Dialog
{
	/**
	 * Displays an "Open" dialog with the specified title. Returns null if
	 * cancelled, otherwise returns the selected path
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 */
	public string? open(string title, Gtk.Window? modal)
	{
		var dialog = new Gtk.FileChooserDialog(title,
			                                   modal,
			                                   Gtk.FileChooserAction.OPEN,
			                                   "gtk-cancel",
			                                   Gtk.ResponseType.CANCEL,
			                                   "gtk-open",
			                                   Gtk.ResponseType.ACCEPT);

		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			string name = dialog.get_filename();
			dialog.destroy();
			return name;
		}
		dialog.destroy();
		return null;
	}

	/**
	 * Creates and runs a "save" dialog with the given title. Returns null if
	 * cancelled, otherwise returns the selected path
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 */
	public string? save(string title, Gtk.Window? modal)
	{
		var dialog = new Gtk.FileChooserDialog(title,
			                                   modal,
			                                   Gtk.FileChooserAction.SAVE,
			                                   "gtk-save",
			                                   Gtk.ResponseType.ACCEPT,
			                                   "gtk-cancel",
			                                   Gtk.ResponseType.CANCEL,
			                                   null);
		
		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			// clean up the file dialog
			string path = dialog.get_filename();
			dialog.destroy();
			return path;
		}
		dialog.destroy();
		return null;
	}
}
