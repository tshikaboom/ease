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
 * An object on a {@link Slide}.
 *
 * Elements form the content of {@link Document}s. The Element class is
 * abstract, so each type of element is represented by a subclass. The Element
 * base class contains properties common to all types of element.
 *
 * To store data, Element uses a key/value store, {@link ElementMap}. All
 * properties of Element and its subclasses are simply wrappers around
 * strings stored in ElementMap. This makes writing to and reading from JSON
 * files very simple.
 *
 * Element is also used in {@link Theme}s, which handle sizing differently.
 *
 * Ease uses a "base resolution" of 1024 by 768, a common projector resolution.
 * Unlike {@link Element}, which expresses positions in x, y, width, and height,
 * a master element expresses them in left, right, top, and bottom. As the total
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
 * same applies to the expand_horizontally property.
 */
public abstract class Ease.Element : GLib.Object
{
	/**
	 * The default width of {@link Theme} master slides.
	 */
	private const float THEME_WIDTH = 800;
	
	/**
	 * The default height of {@link Theme} master slides.
	 */
	private const float THEME_HEIGHT = 600;

	/**
	 * The {@link Slide} that this Element is a part of.
	 */
	public Slide parent { get; set; }
	
	/**
	 * The store of information for this Slide. Data can be accessed either
	 * directly though get() and set(), or though the typed convenience
	 * properties that Element provides.
	 */
	protected ElementMap data;
	
	/**
	 * Creates and returns a copy of this Element.
	 */
	public abstract Element copy();
	
	/**
	 * Create a new element.
	 *
	 * @param owner The slide that this Element belongs to.
	 */
	public Element.with_owner(Slide owner)
	{
		parent = owner;
	}
	
	/**
	 * Get a value, given a key.
	 *
	 * @param key The key to get a value for.
	 */
	public new string get(string key)
	{
		return data.get(key);
	}
	
	/**
	 * Set a value.
	 * 
	 * Element uses a key/value system to make exporting JSON and adding
	 * new types of Elements easy. 
	 *
	 * @param key The map key.
	 * @param val A string to be stored as the key's value.
	 */
	public new void set(string key, string val)
	{
		data.set(key, val);
	}
	
	/**
	 * Output this Element as JSON.
	 * 
	 * Returns a JSON object with the element's data.
	 */
	public Json.Node to_json()
	{
		return data.to_json();
	}
	
	/**
	 * Creates HTML markup for this Element.
	 * 
	 * The <div> tag for this Element is appended to the "HTML" parameter.
	 * This should be inside a <div> tag for the Element's {@link Slide}.
	 *
	 * @param html The HTML string in its current state.
	 * @param exporter The {@link HTMLExporter}, for the path and progress.
	 * @param amount The amount progress should increase by when done.
	 */
	public virtual void to_html(ref string html,
	                            HTMLExporter exporter,
	                            double amount)
	{
		// write the markup
		write_html(ref html, exporter);
		
		// advance the progress bar
		exporter.add_progress(amount);
	}
	
	/**
	 * Creates the actual HTML markup for this Element.
	 *
	 * @param html The HTML string in its current state.
	 * @param exporter The {@link HTMLExporter}, for its path.
	 */
	protected abstract void write_html(ref string html, HTMLExporter exporter);
	
	/**
	 * Renders this Element to a CairoContext.
	 *
	 * @param context The context to render to.
	 */
	public abstract void cairo_render(Cairo.Context context) throws Error;
	
	/**
	 * Returns a ClutterActor for use in presentations and the editor.
	 *
	 * @param c The context of the actor.
	 */
	public abstract Actor actor(ActorContext c);
	
	/**
	 * Creates a new Element from this Element at the specified size.
	 *
	 * @param w The width of the {@link Document} the new Element will be a
	 * part of.
	 * @param w The height of the {@link Document} the new Element will be a
	 * part of.
	 */
	public Element sized_element(float w, float h)
	{
		// copy this element
		var element = copy();
		
		// find the differences in each direction for the new resolution
		var x_diff = (w - THEME_WIDTH) / 2;
		var y_diff = (h - THEME_HEIGHT) / 2;
		
		// set the base size (at 1024x768)
		element.width = THEME_WIDTH - left - right;
		element.height = THEME_HEIGHT - top - bottom;
		
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
	
	/**
	 * A unique identifier for this Element.
	 */
	public string ease_name
	{
		owned get { return data.get("ease_name"); }
		set	{ data.set("ease_name", value);	}
	}
	
	/**
	 * The Element's type: currently "text", "image", or "video".
	 */
	public string element_type
	{
		owned get { return data.get("element_type"); }
		set	{ data.set("element_type", value); }
	}
	
	/**
	 * The Element's identifier on its master {@link Slide}
	 */
	public string identifier
	{
		owned get { return data.get("identifier"); }
		set	{ data.set("identifier", value); }
	}
	
	/**
	 * The X position of this Element.
	 */
	public float x
	{
		get
		{
			return (float)(data.get("x").to_double());
		}
		set
		{
			data.set("x", value.to_string());
		}
	}
	
	/**
	 * The Y position of this Element.
	 */
	public float y
	{
		get
		{
			return (float)(data.get("y").to_double());
		}
		set
		{
			data.set("y", value.to_string());
		}
	}
	
	/**
	 * The width of this Element.
	 */
	public float width
	{
		get
		{
			return (float)(data.get("width").to_double());
		}
		set
		{
			data.set("width", value.to_string());
		}
	}
	
	/**
	 * The height of this Element.
	 */
	public float height
	{
		get
		{
			return (float)(data.get("height").to_double());
		}
		set
		{
			data.set("height", value.to_string());
		}
	}
	
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
}

