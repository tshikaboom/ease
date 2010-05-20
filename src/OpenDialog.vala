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
 * Manages "open file" windows
 * 
 * OpenDialog is a singleton. Before it can be used, init() must be
 * called. After that, a dialog can be opened by calling the static 
 * method run().
 */
public class Ease.OpenDialog : GLib.Object
{
	private static OpenDialog instance;
	
	/**
	 * Initializes OpenDialog. Called when Ease starts.
	 */
	public static void init()
	{
		instance = new OpenDialog();
	}
	
	/**
	 * Displays an "Open" dialog.
	 * 
	 * Used for loading previously saved files. This is a static method.
	 */
	public static void run()
	{
		instance.instance_run();
	}

	private void instance_run()
	{
		var dialog = new Gtk.FileChooserDialog("Open File",
		                                       null,
		                                       Gtk.FileChooserAction.SELECT_FOLDER,
		                                       "gtk-cancel", Gtk.ResponseType.CANCEL,
		                                       "gtk-open", Gtk.ResponseType.ACCEPT, null);

		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			Main.test_editor(dialog.get_filename() + "/");
		}
		dialog.destroy();
	}
}
