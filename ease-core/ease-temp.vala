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
 * Temporary directories are (typically) stored in /tmp/ease/[PID]/[INDEX],
 * where [PID] is the process ID and [INDEX] increments with each new directory.
 * Ease automatically cleans up temporary directories when exiting, and will
 * remove /tmp/ease if no other folders are being used in it.
 *
 * Code that is internal to Ease can also use the request_str() function, which
 * allows a named directory. This is for debugging and cleanliness purposes
 * only - other than the directory name, functionality is identical to
 * request().
 */
public static class Ease.Temp : Object
{
	private static int index = 0;
	
	private static string m_temp;
	private static string temp
	{
		get
		{
			if (m_temp != null) return m_temp;
			m_temp = Path.build_filename(Environment.get_tmp_dir(), TEMP_DIR,
			                             ((int)Posix.getpid()).to_string());
			return m_temp;
		}
	}
	
	private static Gee.LinkedList<string> m_dirs;
	private static Gee.LinkedList<string> dirs
	{
		get
		{
			if (m_dirs != null) return m_dirs;
			return m_dirs = new Gee.LinkedList<string>();
		}
	}
	
	private const int ARCHIVE_BUFFER = 4096;
	public const string TEMP_DIR = "ease";
	public const string THEME_DIR = "themes";
	public const string IMG_DIR = "svg";
	public const string UI_DIR = "ui";
	
	/**
	 * Requests a temporary directory.
	 *
	 * request() creates a temporary directory (typically under /tmp/ease).
	 * Each directory has a integer name, incrementing by one for each new
	 * directory.
	 */
	public static string request() throws GLib.Error
	{	
		// find a safe directory to extract to
		while (exists(index, temp))
		{
			index++;
		}
		
		// build the path
		string tmp = Path.build_filename(temp, index.to_string());
		
		// track the directories used by this instance of the program
		dirs.offer_head(tmp);
		
		// make the directory
		var file = GLib.File.new_for_path(tmp);
		file.make_directory_with_parents(null);
		
		return tmp;
	}
	
	/**
	 * Requests a temporary directory with a specific name.
	 *
	 * This function is useful for debugging and cleanliness purposes.
	 * However, be sure to use unique names. Do not use "integer" strings,
	 * as those could overlap with directories created through request().
	 *
	 * If the directory name is taken, "-0, "-1", etc. will be appended until
	 * an available directory is found.
	 *
	 * @param str The directory name to request.
	 */
	public static string request_str(string str) throws GLib.Error
	{
		// build the path
		string tmp = Path.build_filename(temp, str);
		var file = File.new_for_path(tmp);
		if (file.query_exists(null))
		{
			for (int i = 0; file.query_exists(null); i++)
			{
				tmp = Path.build_filename(temp, str + "-" + i.to_string());
				file = File.new_for_path(tmp);
			}
		}
		
		// track the directories used by this instance of the program
		dirs.offer_head(tmp);
		
		// make the directory
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
	internal static string extract(string filename) throws GLib.Error
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
				var parent = file.get_parent();
				if (!parent.query_exists(null))
				{
					parent.make_directory_with_parents(null);
				}
				
				file.create(FileCreateFlags.REPLACE_DESTINATION, null);
				int fd = Posix.open(fpath, Posix.O_WRONLY, 0644);
				archive.read_data_into_fd(fd);
				Posix.close(fd);
			}
		}
		
		return path;
	}
	
	/**
	 * Creates an archive from a temporary directory.
	 *
	 * archive() uses libarchive to create a tarball of the temporary directory.
	 *
	 * @param temp_path The path of the temporary directory.
	 * @param filename The filename of the archive to save to.
	 */
	internal static void archive(string temp_path, string filename) throws Error
	{
		// create a writable archive
		var archive = new Archive.Write();
		var buffer = new char[ARCHIVE_BUFFER];
		
		// set archive format
		archive.set_format_pax_restricted();
		archive.set_compression_none();
		
		// open file
		if (archive.open_filename(filename) == Archive.Result.FAILED)
		{
			throw new Error(0, 0, "Error opening %s", filename);
		}
		
		// open the temporary directory
		var dir = GLib.Dir.open(temp_path, 0);
		
		// error if the temporary directory has disappeared
		if (dir == null)
		{
			throw new FileError.NOENT(
				_("Temporary directory doesn't exist: %s"), temp_path);
		}
		
		// add files
		recursive_directory(temp_path, null, (path, full_path) => {
			// create an archive entry for the file
			var entry = new Archive.Entry();
			entry.set_pathname(path);
			entry.set_perm(0644);
			Posix.Stat st;
			Posix.stat(full_path, out st);
			entry.copy_stat(st);
			arc_fail(archive.write_header(entry), archive);
			
			// write the file
			var fd = Posix.open(full_path, Posix.O_RDONLY);
			var len = Posix.read(fd, buffer, sizeof(char) * ARCHIVE_BUFFER);
			while(len > 0)
			{
				archive.write_data(buffer, len);
				len = Posix.read(fd, buffer, sizeof(char) * ARCHIVE_BUFFER);
			}
			Posix.close(fd);
			arc_fail(archive.finish_entry(), archive);
		});
		
		// close the archive
		arc_fail(archive.close(), archive);
	}
	
	/**
	 * Produces an error if a libarchive error occurs.
	 */
	private static void arc_fail(Archive.Result result, Archive.Archive archive)
	{
		if (result != Archive.Result.OK) error(archive.error_string());
	}
	
	/**
	 * Deletes all temporary directories created by this instance of Ease.
	 * Call when exiting.
	 */
	public static void clean()
	{
		if (dirs == null) return;

		string dir;
		while ((dir = dirs.poll_head()) != null)
		{
			try { recursive_delete(dir); }
			catch (GLib.Error e)
			{
				debug(e.message);
			}
		}
		
		// Attempt to delete the parent temp directory.
		//
		// This will throw an exception if other instances of Ease are running,
		// but that's what should happen, so we'll just ignore the exception.
		string tmp = Path.build_filename(Environment.get_tmp_dir(), TEMP_DIR);
		try
		{
			// delete [TEMP]/ease/pid
			var file = GLib.File.new_for_path(temp);
			file.delete(null);
			
			// delete [TEMP]/ease
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
	public static bool exists(int dir, string tmp)
	{
		var dir_tmp = Path.build_filename(tmp, dir.to_string());
		var file = GLib.File.new_for_path(dir_tmp);
		
		return file.query_exists(null);
	}
}
