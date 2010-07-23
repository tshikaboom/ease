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
			var sys_file = query_file(Path.build_filename(dir, SYS_DATA), path);
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
	
	/**
	 * Performs a recursive iteration on a directory, with callbacks.
	 *
	 * The caller can provide two {@link RecursiveDirAction}s: one for files,
	 * and another for directories. These callbacks can both be null
	 * (although if they both were, the call would do nothing). The directory
	 * callback is executed before the recursion continues.
	 *
	 * The directory callback is not performed on the toplevel directory.
	 *
	 * @param directory The directory to iterate.
	 * @param directory_action A {@link RecursiveDirAction} to perform on all
	 * directories.
	 * @param file_action A {@link RecursiveDirAction} to perform on all files.
	 */
	public void recursive_directory(string directory,
	                                RecursiveDirAction? directory_action,
	                                RecursiveDirAction? file_action)
	                                throws Error
	{
		do_recursive_directory(directory, directory_action, file_action, "");
	}
	
	/**
	 * Used for execution of recursive_directory(). Should never be called, 
	 * except by that function.
	 */
	private void do_recursive_directory(string directory,
	                                    RecursiveDirAction? directory_action,
	                                    RecursiveDirAction? file_action,
	                                    string rel_path)
	                                    throws Error
	{
		var dir = GLib.Dir.open(directory, 0);
		string child_path;
		
		while ((child_path = dir.read_name()) != null)
		{
			var child_full_path = Path.build_filename(directory, child_path);
			var child_rel_path = Path.build_filename(rel_path, child_path);
			if (FileUtils.test(child_full_path, FileTest.IS_DIR))
			{
				if (directory_action != null)
				{
					directory_action(child_rel_path, child_full_path);
				}
				do_recursive_directory(child_full_path,
				                       directory_action, file_action,
				                       child_rel_path);
			}
			else // the path is a file
			{
				if (file_action != null)
				{
					file_action(child_rel_path, child_full_path);
				}
			}
		}
	}
	
	public delegate void RecursiveDirAction(string path, string full_path);

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
