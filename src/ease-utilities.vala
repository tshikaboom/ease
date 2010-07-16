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

namespace Ease
{
	/**
	 * The local data path.
	 */
	private const string LOCAL_DATA = "data";
	
	/**
	 * The installed data path.
	 */
	private const string SYS_DATA = "ease";
	
	/**
	 * Display a simple error message.
	 *
	 * @param title The title of the dialog.
	 * @param message The error message.
	 */
	public void error_dialog(string title, string message)
	{
		var dialog = new Gtk.MessageDialog(null, 0,
		                                   Gtk.MessageType.ERROR,
		                                   Gtk.ButtonsType.CLOSE,
		                                   "%s", message);
		dialog.title = title;
		dialog.border_width = 5;
		dialog.run();
		dialog.destroy();
	}
	
	/**
	 * Finds the given path in the data directories (ie /usr/share). Return null
	 * if the path cannot be found.
	 *
	 * @param path The path to search for.
	 */
	public string? data_path(string path)
	{
		string file;
		file = query_file(LOCAL_DATA, path);
		if (file != null) return file;
		
		var data_dirs = Environment.get_system_data_dirs();
		foreach (string dir in data_dirs)
		{
			var sys_file = query_file(Path.build_filename(SYS_DATA, dir), path);
			if (sys_file != null) return sys_file;
		}
		
		return null;
	}
	
	/**
	 * Queries the given folder for the file, returning it if it is found.
	 *
	 * Otherwise, the function returns null.
	 *
	 * @param dir The base directory.
	 * @param path The path to search for.
	 */
	private string? query_file(string dir, string path)
	{
		var filename = Path.build_filename(dir, path);
		var file = File.new_for_path(filename);
		
		if (file.query_exists(null))
		{
			return filename;
		}
		return null;
	}

	public double dmax(double a, double b)
	{
		return a > b ? a : b;
	}

	public double dmin(double a, double b)
	{
		return a < b ? a : b;
	}
	
	public int roundd(double num)
	{
		return (int)(num - (int)num < 0.5 ? num : num + 1);
	}
}
