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
 * A master {@link Element}, which supports resizing to different resolutions.
 *
 * MasterElement is mostly a set of extension convenience properties on top of
 * the base {@link Element} class. These properties, list those in
 * {@link Element}, are simply wrappers around data store, {@link ElementMap},
 * translating to and from string.
 *
 * Ease uses a "base resolution" of 1024 by 768, a common projector resolution.
 * Unlike {@link Element}, which expresses positions in x, y, width, and height,
 * MasterElement expressed them in left, right, top, and bottom. As the total
 * size of the presentation is known, the actual sizes can be easily calculated.
 * Then, the Element's size can be increased or decreased by using the
 * four directional bind_ properties and the expand_.
 *
 * For example, the "header" font for a theme will often be selected so that a
 * single line fits perfectly in the space allocated for the header. Therefore,
 * increasing the height at a greater resolution is a waste of space, and
 * decreasing the size at a lower resolution will cause the text not to fit in
 * the box. Therefore, the header should be bound to the top, but not to the
 * bottom. expand_vertically should be false.
 *
 * In contrast, the content box below the header is designed for an arbitrary
 * amount of lines. Therefore, this box should scale vertically, shrinking as
 * the presentation gets smaller, and enlarging as the presentation gets larger.
 * To do this, both bind_bottom and bind_top should be true, as well as
 * expand_vertically.
 *
 * While the bind_left and bind_right properties exist, it's not clear whether
 * or not they will actually be useful at any point. They perform in the same
 * manner as the other two bind_ properties, but for horizontal scaling. The
 * same applies to the expand_horizontally property. In general
 */
public class Ease.MasterElement : Element
{
	private const float WIDTH = 1024;
	private const float HEIGHT = 768;

	/**
	 * If the Element should maintain "top" when resized.
	 *
	 * To scale to different resolutions, MasterElement tracks the distance of
	 * Elements from each edge, and maintains them as these edges expand if the
	 * appropriate bind_ and expand_ properties are true.
	 */
	public bool bind_top
	{
		get { return data.get("bind_top").to_bool(); }
		set { data.set("bind_top", value.to_string()); }
	}
	
	/**
	 * If the Element should maintain "bottom" when resized.
	 *
	 * To scale to different resolutions, MasterElement tracks the distance of
	 * Elements from each edge, and maintains them as these edges expand if the
	 * appropriate bind_ and expand_ properties are true.
	 */
	public bool bind_bottom
	{
		get { return data.get("bind_bottom").to_bool(); }
		set { data.set("bind_bottom", value.to_string()); }
	}
	
	/**
	 * If the Element should maintain "left" when resized.
	 *
	 * To scale to different resolutions, MasterElement tracks the distance of
	 * Elements from each edge, and maintains them as these edges expand if the
	 * appropriate bind_ and expand_ properties are true.
	 */
	public bool bind_left
	{
		get { return data.get("bind_left").to_bool(); }
		set { data.set("bind_left", value.to_string()); }
	}
	
	/**
	 * If the Element should maintain "right" when resized.
	 *
	 * To scale to different resolutions, MasterElement tracks the distance of
	 * Elements from each edge, and maintains them as these edges expand if the
	 * appropriate bind_ and expand_ properties are true.
	 */
	public bool bind_right
	{
		get { return data.get("bind_right").to_bool(); }
		set { data.set("bind_right", value.to_string()); }
	}
	
	/**
	 * If the Element should expand horizontally when resized.
	 *
	 * To scale to different resolutions, MasterElement tracks the distance of
	 * Elements from each edge, and maintains them as these edges expand if the
	 * appropriate bind_ and expand_ properties are true.
	 */
	public bool expand_horizontally
	{
		get { return data.get("expand_horizontally").to_bool(); }
		set { data.set("expand_horizontally", value.to_string()); }
	}
	
	/**
	 * If the Element should expand vertically when resized.
	 *
	 * To scale to different resolutions, MasterElement tracks the distance of
	 * Elements from each edge, and maintains them as these edges expand if the
	 * appropriate bind_ and expand_ properties are true.
	 */
	public bool expand_vertically
	{
		get { return data.get("expand_vertically").to_bool(); }
		set { data.set("expand_vertically", value.to_string()); }
	}
	
	/**
	 * The Element's distance from the top of the screen.
	 */
	public float top
	{
		get { return (float)data.get("top").to_double(); }
		set { data.set("top", value.to_string()); }
	}
	
	/**
	 * The Element's distance from the bottom of the screen.
	 */
	public float bottom
	{
		get { return (float)data.get("bottom").to_double(); }
		set { data.set("bottom", value.to_string()); }
	}
	
	/**
	 * The Element's distance from the left edge of the screen.
	 */
	public float left
	{
		get { return (float)data.get("left").to_double(); }
		set { data.set("left", value.to_string()); }
	}
	
	/**
	 * The Element's distance from the right edge of the screen.
	 */
	public float right
	{
		get { return (float)data.get("right").to_double(); }
		set { data.set("right", value.to_string()); }
	}
	
	/**
	 * Creates an {@link Element} from this MasterElement at the specified size.
	 *
	 * @param w The width of the {@link Document} the new Element will be a
	 * part of.
	 * @param w The height of the {@link Document} the new Element will be a
	 * part of.
	 */
	public Element sized_element(float w, float h)
	{
		// copy this MasterElement into the Element
		var element = copy();
		
		// find the differences in each direction for the new resolution
		var x_diff = (w - WIDTH) / 2;
		var y_diff = (h - HEIGHT) / 2;
		
		// set the base size (at 1024x768)
		element.width = WIDTH - left - right;
		element.height = HEIGHT - top - bottom;
		
		// handle binding to the left
		if (bind_left)
		{
			element.x = left;
			
			if (expand_horizontally)
			{
				element.width += x_diff;
			}
		}
		else
		{
			element.x = left + x_diff; 
		}
		
		// handle binding to the top
		if (bind_top)
		{
			element.y = top;
			
			if (expand_vertically)
			{
				element.height += y_diff;
			}
		}
		else
		{
			element.y = top + y_diff;
		}
		
		// handle binding to the right
		if (bind_right)
		{	
			if (expand_horizontally)
			{
				element.width += x_diff;
			}
		}
		
		// handle binding to the bottom
		if (bind_bottom)
		{	
			if (expand_vertically)
			{
				element.height += y_diff;
			}
		}
		
		return element;
	}
}
