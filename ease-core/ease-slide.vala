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
 * The internal representation of a slide
 *
 * A Slide is owned by a {@link Document} and has {@link Element}
 * children. The currently selected Slide is often acted upon by an
 * EditorWindow (from main Ease, not core).
 */
public class Ease.Slide : GLib.Object, UndoSource
{
	public const string IMAGE_TYPE = "EaseImageElement";
	public const string SHAPE_TYPE = "EaseShapeElement";
	public const string VIDEO_TYPE = "EaseVideoElement";

	/**
	 * The {@link Element}s contained by this Slide
	 */
	internal Gee.ArrayList<Element> elements = new Gee.ArrayList<Element>();
	
	/**
	 * The Slide's transition
	 */
	public Transition transition { get; set; }
	
	/**
	 * The variant (if any) of the Slide's transition
	 */
	public TransitionVariant variant { get; set; }
	
	/**
	 * The duration of this Slide's transition
	 */
	public double transition_time { get; set; }
	
	/**
	 * The duration of this Slide's transition, in milliseconds
	 */
	public uint transition_msecs
	{
		get { return (uint)(transition_time * 1000); }
		set { transition_time = value / 1000f; }
	}
	
	/**
	 * If the slide advances automatically or on key press
	 */
	public bool automatically_advance { get; set; }
	
	/**
	 * If the slide advances automatically, the amount of delay
	 */
	public double advance_delay { get; set; }
	
	/**
	 * The background of this Slide.
	 */
	public Background background { get; set; }
	
	/**
	 * The absolute path of the background image, if one is set.
	 */
	public string background_abs
	{
		owned get
		{
			string p = parent == null ? theme.path : parent.path;
			return Path.build_filename(p, background.image.filename);
		}
	}
	
	/**
	 * The title of this Slide's master (unless the Slide is a master itself)
	 */
	public string title { get; set; }
	
	/**
	 * The {@link Document} that this Slide is part of
	 */
	internal Document parent { get; set; }
	
	/**
	 * The width of the Slide's parent {@link Document}.
	 */
	public int width { get { return parent.width; } }
	
	/**
	 * The height of the Slide's parent {@link Document}.
	 */
	public int height { get { return parent.height; } }
	
	/**
	 * The aspect ratio of the Slide's parent {@link Document}.
	 */
	public float aspect { get { return parent.aspect; } }
	
	/**
	 * The {@link Theme} that this Slide is based on.
	 */
	internal Theme theme { get; set; }
	
	/**
	 * The number of {@link Element}s on this Slide
	 */
	public int count { get { return elements.size; } }
	
	/**
	 * The next Slide in this Slide's {@link Document}.
	 */
	public Slide? next
	{
		owned get
		{
			for (int i = 0; i < parent.slides.size - 1; i++)
			{
				if (parent.get_slide(i) == this)
				{
					return parent.get_slide(i + 1);
				}
			}
			return null;
		}
	}
	
	/**
	 * The previous Slide in this Slide's {@link Document}.
	 */
	public Slide? previous
	{
		owned get
		{
			for (int i = 1; i < parent.slides.size; i++)
			{
				if (parent.get_slide(i) == this)
				{
					return parent.get_slide(i - 1);
				}
			}
			return null;
		}
	}
	
	/**
	 * Emitted when an {@link Element} or property of this Slide is changed.
	 */
	public signal void changed(Slide self);
	
	/**
	 * Emitted when the background of this Slide is altered in any way.
	 */
	public signal void background_changed(Slide self);
	
	/**
	 * Emitted when an {@link Element} is added to this Slide.
	 */
	public signal void element_added(Slide self, Element element, int index);
	
	/**
	 * Emitted when an {@link Element} is added to this Slide.
	 */
	public signal void element_removed(Slide self, Element element, int index);
	
	/**
	 * Create a new Slide.
	 */
	public Slide()
	{
		background = new Background();
		
		// inspect undo actions passed through the slide, check for bg changes
		undo.connect((item) => {
			if (background.owns_undoitem(item)) background_changed(this);
		});
	}
	
	/**
	 * Create a new Slide assigned to a {@link Document}.
	 * 
	 * Used for loading previously saved files. 
	 *
	 * @param owner The {@link Document} this slide is a part of.
	 */
	public Slide.with_owner(Document owner)
	{
		this();
		parent = owner;
	}
	
	/**
	 * Constructs a Slide from a JsonObject.
	 */
	internal Slide.from_json(Json.Object obj)
	{
		this();
		
		var slide = new Slide();
		
		// read the slide's transition properties
		transition = Transition.from_string(
			obj.get_string_member("transition"));
			
		variant = TransitionVariant.from_string(
			obj.get_string_member("variant"));
			
		transition_time = obj.get_string_member("transition_time").to_double();
			
		automatically_advance = 
			obj.get_string_member("automatically_advance").to_bool();
			
		advance_delay =
			obj.get_string_member("advance_delay").to_double();
		
		title = obj.get_string_member("title");
		
		// read the slide's background properties
		if (obj.has_member(Theme.BACKGROUND_IMAGE))
		{
			background.image.filename = obj.get_string_member(Theme.BACKGROUND_IMAGE);
			background.image.source =
				obj.get_string_member("background-image-source");
		}
		if (obj.has_member(Theme.BACKGROUND_COLOR))
		{
			background.color =
				new Color.from_string(
				obj.get_string_member(Theme.BACKGROUND_COLOR));
		}
		if (obj.has_member(Theme.BACKGROUND_GRADIENT))
		{
			background.gradient =
				new Gradient.from_string(
				obj.get_string_member(Theme.BACKGROUND_GRADIENT));
		}
		background.background_type = BackgroundType.from_string(
			obj.get_string_member(Theme.BACKGROUND_TYPE));
		
		// parse the elements
		var elements = obj.get_array_member("elements");
		
		for (var i = 0; i < elements.get_length(); i++)
		{
			var node = elements.get_object_element(i);
			
			// find the proper type
			var type = node.get_string_member(Theme.ELEMENT_TYPE);
			Element e;
			
			if (type == IMAGE_TYPE)
			{
				e = new ImageElement.from_json(node);
			}
			else if (type == SHAPE_TYPE)
			{
				e = new ShapeElement.from_json(node);
			}
			else if (type == VIDEO_TYPE)
			{
				e = new VideoElement.from_json(node);
			}
			else
			{
				e = new TextElement.from_json(node);
			}
			e.element_type = type;
			add_element(slide.count, e);
		}
	}
	
	internal Json.Node to_json()
	{
		var node = new Json.Node(Json.NodeType.OBJECT);
		var obj = new Json.Object();
		
		// write the slide's transition properties
		obj.set_string_member("transition", transition.to_string());
		obj.set_string_member("variant", variant.to_string());
		obj.set_string_member("transition_time", transition_time.to_string());
		obj.set_string_member("automatically_advance",
		                      automatically_advance.to_string());
		obj.set_string_member("advance_delay", advance_delay.to_string());
		obj.set_string_member("title", title);
		
		// write the slide's background properties
		if (background.image.filename != null)
		{
			obj.set_string_member(Theme.BACKGROUND_IMAGE,
			                      background.image.filename);
			obj.set_string_member("background-image-source",
			                      background.image.source);
		}
		if (background.color != null)
		{
			obj.set_string_member(Theme.BACKGROUND_COLOR,
			                      background.color.to_string());
		}
		if (background.gradient != null)
		{
			obj.set_string_member(Theme.BACKGROUND_GRADIENT,
			                      background.gradient.to_string());
		}
		obj.set_string_member(Theme.BACKGROUND_TYPE,
		                      background.background_type.to_string());
		
		// add the slide's elements
		var json_elements = new Json.Array();
		foreach (var e in elements)
		{
			Json.Node e_node = new Json.Node(Json.NodeType.OBJECT);
			e_node.set_object(e.to_json());
			json_elements.add_element(e_node.copy());
		}

		obj.set_array_member("elements", json_elements);
		
		node.set_object(obj);
		return node;
	}
	
	/**
	 * Adds an {@link Element} to this slide at a specified index.
	 *
	 * @param index The index to add the {@link Element} at.
	 * @param e The {@link Element} to add.
	 */
	public void add_element(int index, Element e)
	{
		e.parent = this;
		elements.insert(index, e);
		element_added(this, e, index);
		listen(e);
	}
	
	/**
	 * Adds an {@link Element} to this slide at the end index.
	 * 
	 * @param e The element to add;.
	 */
	public void add(Element e)
	{
		add_element(count, e);
	}
	
	/**
	 * Removes an {@link Element} from this slide.
	 */
	public void remove_element(Element e)
	{
		var index = index_of(e);
		elements.remove(e);
		element_removed(this, e, index);
		silence(e);
	}
	
	/**
	 * Removed an {@link Element} from this slide, by index.
	 */
	public void remove_at(int index)
	{
		var e = elements.get(index);
		elements.remove_at(index);
		element_removed(this, e, index);
		silence(e);
	}
	
	/**
	 * Returns the index of the specified {@link Element}
	 */
	public int index_of(Element e)
	{
		return elements.index_of(e);
	}
	
	/**
	 * Returns the {@link Element} at the specified index.
	 */
	public Element element_at(int i)
	{
		return elements.get(i);
	}
	
	/** 
	 * Draws the {@link Slide} to a Cairo.Context.
	 *
	 * @param context The Cairo.Context to draw to.
	 */
	public void cairo_render(Cairo.Context context) throws GLib.Error
	{
		if (parent == null)
			throw new GLib.Error(0, 0, "Slide must have a parent document");
		
		cairo_render_sized(context, parent.width, parent.height);
	}
	
	/** 
	 * Draws the {@link Slide} to a Cairo.Context at a specified size.
	 *
	 * @param context The Cairo.Context to draw to.
	 * @param w The width to render at.
	 * @param h The height to render at.
	 */
	public void cairo_render_sized(Cairo.Context context,
	                               int w, int h) throws GLib.Error
	{
		context.save();
		cairo_render_background(context, w, h);
		context.restore();
		
		foreach (var e in elements)
		{
			context.save();
			context.translate(e.x, e.y);
			e.cairo_render(context);
			context.restore();
		}
	}
	
	/** 
	 * Draws the slide's background to a Cairo.Context at a specified size.
	 *
	 * @param cr The Cairo.Context to draw to.
	 * @param w The width to render at.
	 * @param h The height to render at.
	 */
	public void cairo_render_background(Cairo.Context cr,
	                                    int w, int h) throws GLib.Error
	{
		cr.save();
		background.set_cairo(cr, w, h,
		                     parent == null ? theme.path : parent.path);
		cr.rectangle(0, 0, w, h);
		cr.fill();
		cr.restore();
	}
	
	/**
	 * Creates HTML markup for this Slide.
	 * 
	 * The <div> tag for this Slide is appended to the "HTML" parameter.
	 *
	 * @param html The HTML string in its current state.
	 * @param exporter The {@link HTMLExporter}, for the path and progress.
	 * @param amount The amount progress should increase by when done.
	 * @param index The index of this slide.
	 */
	public void to_html(ref string html,
	                    HTMLExporter exporter,
	                    double amount,
	                    int index)
	{
		// create the slide opening tag
		html += "<div class=\"slide\" id=\"slide" +
		        index.to_string() + "\" ";
		
		if (background.image.filename == null)
		{
			// give the slide a background color
			html += "style=\"background-color: " +
			        background.color.clutter.to_string().
			        substring(0, 7) + "\">";
		}
		else
		{
			// close the tag
			html += ">";
			
			// add the background image
			html += "<img src=\"" + exporter.basename + " " + background.image.filename +
			        "\" alt=\"Background\" width=\"" +
			        parent.width.to_string() + "\" height=\"" +
			        parent.height.to_string() + "\"/>";

			// copy the image file
			exporter.copy_file(background.image.filename, parent.path);
		}
		
		// add tags for each Element
		foreach (var e in elements)
		{
			e.to_html(ref html, exporter, amount / elements.size);
		}
		
		html += "</div>\n";
	}

	// foreach iteration
	
	/**
	 * Returns an iterator that can be used with foreach.
	 */
	public Iterator iterator()
	{
		return new Iterator(this);
	}
	
	/**
	 * Iterates over this Slide's elements.
	 */
	public class Iterator
	{
		private int i = 0;
		private Slide self;
		
		public Iterator(Slide slide)
		{
			self = slide;
		}
		
		public bool next()
		{
			return i < self.elements.size;
		}
		
		public Element get()
		{
			i++;
			return self.elements.get(i - 1);
		}
	}
}

