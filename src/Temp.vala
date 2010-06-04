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
 * Creates temporary directories for use by Ease.
 */
public static class Ease.Temp : Object
{
	private static int index = 0;
	
	/**
	 * Requests a temporary directory.
	 *
	 * request() creates a temporary directory (typically under /tmp/ease).
	 * Each directory has a integer name, incrementing by one for each new
	 * directory.
	 */
	public static string request() throws GLib.Error
	{
		// remove any temporary directories from previous runs of Ease
		if (index == 0)
		{
			string tmp = Environment.get_tmp_dir();
			var file =
				GLib.File.new_for_path(Path.build_path("/", tmp, "ease"));
			
			if (file.query_exists(null))
			{
				// TODO: not this
				Posix.system("rm -rf /tmp/ease");
//				var enumerator = file.enumerate_children("standard::", 0, null);
//				
//				var info = enumerator.next_file(null);
//				while (info != null)
//				{
//					stdout.printf("%s\n", info.get_display_name());
//					info = enumerator.next_file(null);
//				}
//				
//				file.delete(null);
			}
		}
		
		index++;
		
		// build the path
		string tmp = Environment.get_tmp_dir();
		tmp = Path.build_path("/", tmp, "ease", index.to_string());
		
		// make the directory
		var file = GLib.File.new_for_path(tmp);
		file.make_directory_with_parents(null);
		
		return tmp;
	}
}
