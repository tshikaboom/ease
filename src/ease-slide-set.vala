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
 * A base class for {@link Document} and {@link Theme}.
 */
public abstract class Ease.SlideSet : Object
{
	private const string MEDIA_PATH = "Media";

	/**
	 * The filename of the of the SlideSet when archived. Typically, this is a
	 * .ease or .easetheme file.
	 */
	public string filename { get; set; }
	
	/**
	 * The file path of the SlideSet (extracted).
	 */
	public string path { get; set; }

	/**
	 * All {@link Slide}s in this SlideSet.
	 */
	public Gee.ArrayList<Slide> slides = new Gee.ArrayList<Slide>();
	
	/**
	 * The number of {@link Slide}s in the SlideSet.
	 */
	public int length { get { return slides.size; } }
	
	/**
	 * Inserts a new {@link Slide} into the SlideSet.
	 *
	 * @param s The {@link Slide} to insert.
	 * @param index The position of the new {@link Slide} in the SlideSet.
	 */
	public virtual void add_slide(int index, Slide s)
	{
		slides.insert(index, s);
	}
	
	/**
	 * Adds a new {@link Slide} to the end of the SlideSet.
	 *
	 * @param s The {@link Slide} to append.
	 */
	public virtual void append_slide(Slide s)
	{
		slides.insert(length, s);
	}
	
	/**
	 * Finds the index of the given slide, or returns -1 if it is not found.
	 *
	 * @param s The {@link Slide} to find the index of.
	 */
	public int index_of(Slide s)
	{
		for (int i = 0; i < slides.size; i++)
		{
			if (slides.get(i) == s)
			{
				return i;
			}
		}
		return -1;
	}
	
	/**
	 * Finds a {@link Slide} by its "title" property.
	 *
	 * @param id The title to search for.
	 */
	public Slide? slide_by_title(string title)
	{
		foreach (Slide s in slides)
		{
			if (s.title == title)
			{
				return s;
			}
		}
		return null;
	}
	
	/**
	 * Copies all files under Media/ to a new directory.
	 *
	 * @param target The path to copy media files to.
	 */
	public void copy_media(string target) throws GLib.Error
	{
		var origin_path = Path.build_filename(path, MEDIA_PATH);
		
		var target_path = Path.build_filename(target, MEDIA_PATH);
		
		// TODO: non-system implementation of recursive copy
		Posix.system("cp -r %s %s".printf(origin_path, target_path));
	}
	
	/**
	 * Copies a media file to the temporary directory.
	 *
	 * Returns the path to the new file, as it should be stored in the
	 * document when saved.
	 *
	 * @param file The path to the file that will be copied.
	 */
	public string add_media_file(string file) throws GLib.Error
	{
		// create the media directory if necessary
		var media = File.new_for_path(Path.build_filename(path, MEDIA_PATH));
		if (!media.query_exists(null)) media.make_directory_with_parents(null);
		
		// create file paths
		var orig = File.new_for_path(file);
		var rel_path = Path.build_filename(MEDIA_PATH, orig.get_basename());
		var dest = File.new_for_path(Path.build_filename(path, rel_path));
		
		// if the file exists, we need a new filename
		for (int i = 0; dest.query_exists(null); i++)
		{
			rel_path = Path.build_filename(MEDIA_PATH, i.to_string() + "-" +
			                               orig.get_basename());
			dest = File.new_for_path(Path.build_filename(path, rel_path));
		}
		
		// copy the file and return its path
		orig.copy(dest, 0, null, null);
		return rel_path;
	}
}

