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

internal class Ease.Archiver : GLib.Object
{
	private string temp_path;
	private string filename;
	private Dialogs.Progress dialog;
	private unowned Thread thread;
	private bool async = true;
	private int total_size = 0;
	
	private static GLib.List<Archiver> archivers = new GLib.List<Archiver>();
	
	private const int ARCHIVE_BUFFER = 4096;
	private const string LABEL_TEXT = _("Saving \"%s\"");
	
	/**
	 * The minimum filesize at which asynchronous saving is used.
	 */
	private const int ASYNC_SIZE = 1024 * 1024 * 5;
	
	internal Archiver(string temp, string fname, Dialogs.Progress dlog)
	{
		temp_path = temp;
		filename = fname;
		dialog = dlog;
		archivers.append(this);
		
		// this is a little redundant, probably not a huge perf hit though
		recursive_directory(temp_path, null, (path, full_path) => {
			Posix.Stat st;
			Posix.stat(full_path, out st);
			total_size += (int)st.st_size;
		});
		
		if (!Thread.supported() || total_size < ASYNC_SIZE)
		{
			// fall back on non-async archiving
			async = false;
			archive_real();
			return;
		}
		
		dialog.set_label(LABEL_TEXT.printf(filename));
		dialog.show();
		thread = Thread.create(archive_real, true);
	}
	
	/**
	 * Does the actual archiving of a directory.
	 */
	private void* archive_real()
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
			
			double size = (double)st.st_size;
			double size_frac = size / total_size;
			
			// write the file
			var fd = Posix.open(full_path, Posix.O_RDONLY);
			var len = Posix.read(fd, buffer, sizeof(char) * ARCHIVE_BUFFER);
			while(len > 0)
			{
				archive.write_data(buffer, len);
				len = Posix.read(fd, buffer, sizeof(char) * ARCHIVE_BUFFER);
				lock (dialog) dialog.add_fraction(size_frac * (len / size));
			}
			Posix.close(fd);
			arc_fail(archive.finish_entry(), archive);
		});
		
		// close the archive
		arc_fail(archive.close(), archive);
		
		// destroy the progress dialog in async mode
		lock (dialog) if (async) dialog.destroy();
		
		// stop tracking this archiver
		lock (archivers) { archivers.remove(this); }
		
		return null;
	}
	
	/**
	 * Produces an error if a libarchive error occurs.
	 */
	private static void arc_fail(Archive.Result result, Archive.Archive archive)
	{
		if (result != Archive.Result.OK) critical(archive.error_string());
	}
}

namespace Ease
{
	/**
	 * Asynchronously (if supported) creates an archive from a temporary
	 * directory. Otherwise, falls back on synchronous archiving.
	 *
	 * archive() uses libarchive to create a tarball of the temporary directory.
	 *
	 * @param temp_path The path of the temporary directory.
	 * @param filename The filename of the archive to save to.
	 * @param title The title of the progress dialog.
	 * @param win The window to display a progress dialog modal for.
	 */
	internal static void archive(string temp_path,
		                         string filename,
		                         string title,
		                         Gtk.Window? win) throws Error
	{
		// create a progress dialog
		var dialog = new Dialogs.Progress(title, false, 1, win);
	
		// archive away!
		var arc = new Archiver(temp_path, filename, dialog);
	}
}
