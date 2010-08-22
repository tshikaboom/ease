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
	 * cancelled, otherwise returns the selected path.
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 */
	public string? open(string title, Gtk.Window? modal)
	{
		return open_ext(title, modal, null);
	}
	
	/**
	 * Displays an "Open" dialog with the specified title. The
	 * {@link FileChooserDialogExtension} can be used to modify the
	 * dialog before it is displayed. Returns null if cancelled, otherwise
	 * returns the selected path.
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 * @param ext A function to modify the dialog before it is displayed.
	 */
	public string? open_ext(string title, Gtk.Window? modal,
	                        FileChooserDialogExtension? ext)
	{
		var dialog = new Gtk.FileChooserDialog(title,
			                                   modal,
			                                   Gtk.FileChooserAction.OPEN,
			                                   "gtk-cancel",
			                                   Gtk.ResponseType.CANCEL,
			                                   "gtk-open",
			                                   Gtk.ResponseType.ACCEPT);
		if (ext != null) ext(dialog);

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
	 * Displays an "Open" dialog for an Ease {@link Document}. Returns null if
	 * cancelled, otherwise returns the selected path.
	 *
	 * @param modal The window that the dialog should be modal for.
	 */
	public string? open_document(Gtk.Window? modal)
	{
		return open_ext(_("Open Document"), modal, (dialog) => {
			// add a filter for ease documents
			var filter = new Gtk.FileFilter();
			filter.add_pattern("*.ease");
			filter.set_name(_("Ease Presentations"));
			dialog.add_filter(filter);
			
			// add a filter for all files
			filter = new Gtk.FileFilter();
			filter.set_name(_("All Files"));
			filter.add_pattern("*");
			dialog.add_filter(filter);
		});
	}
	
	/**
	 * Displays an "Save" dialog with the specified title. Returns null if
	 * cancelled, otherwise returns the selected path.
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 */
	public string? save(string title, Gtk.Window? modal)
	{
		return save_ext(title, modal, null);
	}

	/**
	 * Displays an "Save" dialog with the specified title. The
	 * {@link FileChooserDialogExtension} can be used to modify the
	 * dialog before it is displayed. Returns null if cancelled, otherwise
	 * returns the selected path.
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 * @param ext A function to modify the dialog before it is displayed.
	 */
	public string? save_ext(string title, Gtk.Window? modal,
	                        FileChooserDialogExtension? ext)
	{
		var dialog = new Gtk.FileChooserDialog(title,
			                                   modal,
			                                   Gtk.FileChooserAction.SAVE,
			                                   "gtk-save",
			                                   Gtk.ResponseType.ACCEPT,
			                                   "gtk-cancel",
			                                   Gtk.ResponseType.CANCEL,
			                                   null);
		if (ext != null) ext(dialog);
		
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
	
	/**
	 * Displays an "Save" dialog for an Ease {@link Document}. Returns null if
	 * cancelled, otherwise returns the selected path. The title parameter
	 * is provided to differentiate between "Save", "Save as", etc.
	 *
	 * @param title The dialog's title.
	 * @param modal The window that the dialog should be modal for.
	 */
	public string? save_document(string title, Gtk.Window? modal)
	{
		return save_ext(title, modal, (dialog) => {
			// add a filter for ease documents
			var filter = new Gtk.FileFilter();
			filter.add_pattern("*.ease");
			filter.set_name(_("Ease Presentations"));
			dialog.add_filter(filter);
			
			// add a filter for all files
			filter = new Gtk.FileFilter();
			filter.set_name(_("All Files"));
			filter.add_pattern("*");
			dialog.add_filter(filter);
		});
	}
	
	/**
	 * Allows a caller to manipulate a dialog before is is displayed.
	 */
	public delegate void FileChooserDialogExtension(Gtk.FileChooserDialog d);
}

