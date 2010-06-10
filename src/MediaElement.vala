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
 * An abstract subclass of {@link Element} with a path to a media file.
 */
public abstract class Ease.MediaElement : Element
{
	/**
	 * The path to a media file. Applies to "image" and "video" Elements.
	 */
	public string filename
	{
		owned get { return data.get("filename"); }
		set	{ data.set("filename", value); }
	}
	
	/**
	 * The full path to a media file. Applies to "image" and "video"
	 * Elements. Cannot be set.
	 */
	public string full_filename
	{
		owned get
		{
			var str = Path.build_filename(parent.parent.path, filename);
			return str;
		}
	}
}
