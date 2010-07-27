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
 */
public abstract class Ease.Element : GLib.Object, UndoSource
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
	 * The {@link Document} that this Element is part of. get-only.
	 */
	public Document document { get { return parent.parent; } }
	
	/**
	 * Creates an Element from a JsonObject
	 */
	internal Element.from_json(Json.Object obj)
	{
		identifier = obj.get_string_member(Theme.E_IDENTIFIER);
		x = (float)obj.get_string_member(Theme.X).to_double();
		y = (float)obj.get_string_member(Theme.Y).to_double();
		width = (float)obj.get_string_member(Theme.WIDTH).to_double();
		height = (float)obj.get_string_member(Theme.HEIGHT).to_double();
		has_been_edited =
			obj.get_string_member(Theme.HAS_BEEN_EDITED).to_bool();
	}
	
	/**
	 * Writes an Element to a JsonObject
	 */
	internal virtual Json.Object to_json()
	{
		var obj = new Json.Object();
		
		obj.set_string_member(Theme.E_IDENTIFIER, identifier);
		obj.set_string_member(Theme.ELEMENT_TYPE, get_type().name());
		obj.set_string_member(Theme.X, x.to_string());
		obj.set_string_member(Theme.Y, y.to_string());
		obj.set_string_member(Theme.WIDTH, width.to_string());
		obj.set_string_member(Theme.HEIGHT, height.to_string());
		obj.set_string_member(Theme.HAS_BEEN_EDITED,
		                      has_been_edited.to_string());
		
		return obj;
	}
	
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
	 * Returns an {@link Inspector} widget for editing this Element.
	 */
	public abstract Gtk.Widget inspector_widget();
	
	/**
	 * Returns a GList of ToolItems to add to the main toolbar when this
	 * Element is selected.
	 */
	public virtual GLib.List<Gtk.ToolItem>? tool_items()
	{
		return null;
	}
	
	/**
	 * If applicable, this method sets the color of an Element and returns true.
	 * Otherwise, it returns false. The method should be overridden by
	 * subclasses that provide a "color" property.
	 *
	 * @param c The color to set the element to.
	 */
	public virtual bool set_color(Clutter.Color c)
	{
		return false;
	}
	
	/**
	 * If applicable, this method returns the color of an Element. By default,
	 * it returns null. Subclasses that provide a color property should override
	 * this method.
	 */
	public virtual Clutter.Color? get_color()
	{
		return null;
	}
	
	/**
	 * The Element's identifier on its master {@link Slide}.
	 *
	 * This property allows Ease to simply change the theme of a {@link Slide}.
	 * Elements can be quickly matched up and updated appropriately.
	 */
	public string identifier { get; set; }
	
	/**
	 * The Element's type: currently "text", "image", or "video".
	 */
	public string element_type { get; set; }
	
	/**
	 * The X position of this Element.
	 */
	public float x { get; set; }
	
	/**
	 * The Y position of this Element.
	 */
	public float y { get; set; }
	
	/**
	 * The width of this Element.
	 */
	public float width { get; set; }
	
	/**
	 * The height of this Element.
	 */
	public float height { get; set; }
	
	/**
	 * If the Element has been edited by the user in the past.
	 */
	public bool has_been_edited { get; set; }
}

