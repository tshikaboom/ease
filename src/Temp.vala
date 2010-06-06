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
 *
 * Temporary directories are (typically) stored in /tmp/ease/{PID}/{INDEX},
 * where {PID} is the process ID and {INDEX} increments with each new directory.
 * Ease automatically cleans up temporary directories when exiting, and will
 * remove /tmp/ease if no other folders are being used in it.
 */
public static class Ease.Temp : Object
{
	private static int index = 0;
	private static int pid;
	private static string temp;
	
	private static Gee.LinkedList<string> folders;
	
	private const int ARCHIVE_BUFFER = 4096;
	private const string TEMP_DIR = "ease";
	
	/**
	 * Requests a temporary directory.
	 *
	 * request() creates a temporary directory (typically under /tmp/ease).
	 * Each directory has a integer name, incrementing by one for each new
	 * directory.
	 */
	public static string request() throws GLib.Error
	{
		if (folders == null)
		{
			folders = new Gee.LinkedList<string>();
			pid = Posix.getpid();
			
			temp = Path.build_filename(Environment.get_tmp_dir(), TEMP_DIR,
			                           pid.to_string());
		}
		
		// find a safe directory to extract to
		while (exists(index, temp))
		{
			index++;
		}
		
		// build the path
		string tmp = Path.build_filename(temp, index.to_string());
		
		// track the directories used by this instance of the program
		folders.offer_head(tmp);
		
		// make the directory
		var file = GLib.File.new_for_path(tmp);
		file.make_directory_with_parents(null);
		
		return tmp;
	}
	
	/**
	 * Creates a temporary directory and extracts an archive to it.
	 *
	 * extract() uses libarchive for extraction. It will automatically request
	 * a new temporary directory, extract the archive, and return the path
	 * to the extracted files.
	 *
	 * @param filename The path of the archive to extract.
	 */
	public static string extract(string filename) throws GLib.Error
	{
		// initialize the archive
		var archive = new Archive.Read();
		
		// automatically detect archive type
		archive.support_compression_all();
		archive.support_format_all();
		
		// open the archive
		archive.open_filename(filename, ARCHIVE_BUFFER);
		
		// create a temporary directory to extract to
		string path = request();
		
		// extract the archive
		weak Archive.Entry entry;
		while (archive.next_header(out entry) == Archive.Result.OK)
		{
			var fpath = Path.build_filename(path, entry.pathname());
			var file = GLib.File.new_for_path(fpath);
			if (Posix.S_ISDIR(entry.mode()))
			{
				file.make_directory_with_parents(null);
			}
			else
			{
				file.create(FileCreateFlags.REPLACE_DESTINATION, null);
				int fd = Posix.open(fpath, Posix.O_WRONLY, 0644);
				archive.read_data_into_fd(fd);
				Posix.close(fd);
			}
		}
		
		return path;
	}
	
	/**
	 * Deletes all temporary directories created by this instance of Ease.
	 * Call when exiting.
	 */
	public static void clean()
	{
		string dir;
		while ((dir = folders.poll_head()) != null)
		{
			// TODO: not this
			Posix.system("rm -rf %s".printf(dir));
		}
		
		// Attempt to delete the parent temp directory.
		//
		// This will throw an exception if other instances of Ease are running,
		// but that's what should happen, so we'll just ignore the exception.
		string tmp = Path.build_filename(Environment.get_tmp_dir(), TEMP_DIR);
		try
		{
			// delete {TEMP}/ease/pid
			var file = GLib.File.new_for_path(temp);
			file.delete(null);
			
			// delete {TEMP}/ease
			file = GLib.File.new_for_path(tmp);
			file.delete(null);
		}
		catch (Error e) {}
	}
	
	/**
	 * Checks if a temporary directory already exists.
	 *
	 * @param dir The index of the directory.
	 * @param tmp The parent temporary directory (typically /tmp/ease).
	 */
	private static bool exists(int dir, string tmp)
	{
		var dir_tmp = Path.build_filename(tmp, dir.to_string());
		var file = GLib.File.new_for_path(dir_tmp);
		
		return file.query_exists(null);
	}
}
