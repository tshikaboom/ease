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
	/**
	 * The file path of the SlideSet.
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
	 * Adds a new {@link Slide to the end of the SlideSet.
	 *
	 * @param s The {@link Slide} to append.
	 */
	public void append_slide(Slide s)
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
}

