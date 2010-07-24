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
 * Internal representation of Ease themes.
 */
public class Ease.Theme : GLib.Object
{
	// file paths
	private const string DEFAULTS_PATH = "theme-defaults.json";
	public const string JSON_PATH = "Theme.json";
	private const string MEDIA_PATH = "Media";
	
	// json root elements
	private const string MASTERS = "masters";
	private const string ELEMENTS = "elements";
	private const string MASTER_DEF = "master-defaults";
	private const string ELEMENT_DEF = "element-defaults";
	private const string THEME_TITLE = "title";
	private const string THEME_AUTHOR = "author";
	
	// master slides
	public const string TITLE = "title";
	public const string CONTENT = "content";
	public const string CONTENT_HEADER = "content-header";
	public const string CONTENT_DUAL = "content-dual";
	public const string CONTENT_DUAL_HEADER = "content-dual-header";
	public const string MEDIA = "media";
	public const string MEDIA_HEADER = "media-header";
	
	/**
	 * String identifiers for all master slides available in Ease.
	 */
	public const string[] MASTER_SLIDES = {
		TITLE,
		CONTENT,
		CONTENT_HEADER,
		CONTENT_DUAL,
		CONTENT_DUAL_HEADER,
		MEDIA,
		MEDIA_HEADER
	};
	
	// master slide properties
	public const string BACKGROUND_COLOR = "background-color";
	public const string S_IDENTIFIER = "slide-identifier";
	
	// text content types
	private const string TITLE_TEXT = "title-text";
	private const string AUTHOR_TEXT = "author-text";
	private const string CONTENT_TEXT = "content-text";
	private const string HEADER_TEXT = "header-text";
	
	// text properties
	public const string TEXT_FONT = "text-font";
	public const string TEXT_SIZE = "text-size";
	public const string TEXT_STYLE = "text-style";
	public const string TEXT_VARIANT = "text-variant";
	public const string TEXT_WEIGHT = "text-weight";
	public const string TEXT_ALIGN = "text-align";
	public const string TEXT_COLOR = "text-color";
	
	// generic element properties
	public const string E_IDENTIFIER = "element-identifier";
	
	/**
	 * The text properties, excluding color, which must be set in a custom way.
	 */
	private const string[] TEXT_PROPS = {
		TEXT_FONT,
		TEXT_SIZE,
		TEXT_STYLE,
		TEXT_VARIANT,
		TEXT_WEIGHT,
		TEXT_ALIGN
	};
	
	// media content types
	public const string CONTENT_MEDIA = "content-media";
	
	// generic element properties
	public const string PAD_LEFT = "padding-left";
	public const string PAD_RIGHT = "padding-right";
	public const string PAD_TOP = "padding-top";
	public const string PAD_BOTTOM = "padding-bottom";
	public const string WIDTH = "width";
	public const string HEIGHT = "height";
	
	/**
	 * The title of the Theme.
	 */
	public string title;
	
	/**
	 * The path to the theme's extracted files.
	 */
	public string path { get; set; }
	
	/**
	 * A map of internal master slide settings overriden by the theme.
	 */
	private Gee.Map<string, Gee.Map<string, string>> masters;
	
	/**
	 * A map of internal element settings overriden by the theme.
	 */
	private Gee.Map<string, Gee.Map<string, string>> elements;
	
	/**
	 * A map of master slide settings, used as a fallback for all masters when
	 * the specified master does not provide the given property.
	 *
	 * For example, the background properties are typically the same
	 * throughout the theme. This is an efficient place for those properties.
	 */
	private Gee.Map<string, string> master_defaults;
	
	/**
	 * A map of element settings, used as a fallback for all elements when
	 * the specified element does not provide the given property.
	 *
	 * For example, the text-font property is often the same throughout the
	 * theme. This is an efficient place for properties like that.
	 */
	private Gee.Map<string, string> element_defaults;
	
	/**
	 * A Theme containing default values for elements and master slides.
	 */
	private static Theme defaults
	{
		get
		{
			if (defaults_store != null) return defaults_store;
			return defaults_store = new Theme.json(data_path(DEFAULTS_PATH));
		}
	}
	
	/**
	 * Storage for "defaults" property.
	 */
	private static Theme defaults_store;

	/**
	 * Creates an empty Theme.
	 *
	 * @param path The path to the theme's archive.
	 */
	public Theme(string archive_path)
	{
		// extract the theme
		try
		{
			path = Temp.extract(archive_path);
		}
		catch (GLib.Error e)
		{
			error_dialog(_("Error Loading Theme"),
			             (_("Error loading theme: %s") + "\n\n" + e.message).
			             printf(path));
			return;
		}
		
		load_from_json(Path.build_filename(path, JSON_PATH));
	}
	
	/**
	 * Loads a Theme from pure JSON, (no archive).
	 *
	 * This constructor is used to load the defaults. It is also used when
	 * loading a previously saved {@link Document}.
	 *
	 * @param json_path The path to the JSON file.
	 */
	public Theme.json(string json_path)
	{
		load_from_json(json_path);
	}
	
	/**
	 * Creates a "shallow" copy of a Theme.
	 *
	 * This constructor does not copy any data from the provided Theme. It
	 * instead creates a new set of references to the same data.
	 *
	 * @param copy_from The Theme to copy from.
	 */
	private Theme.copy(Theme copy_from)
	{
		// note that this doesn't duplicate the maps
		masters = copy_from.masters;
		elements = copy_from.elements;
		master_defaults = copy_from.master_defaults;
		element_defaults = copy_from.element_defaults;
		title = copy_from.title;
		path = copy_from.path;
	}
	
	/**
	 * Copies a Theme's data files to a specified path, returning a Theme
	 * pointing to those files.
	 *
	 * This method uses the private Theme.copy() constructor. This constructor
	 * performs a shallow copy - thus, the Gee.Maps holding the Theme's data
	 * are the same for both themes. This is OK, because Themes should never be
	 * modified after they are first loaded.
	 *
	 * @param copy_to The path to copy the Theme to.
	 */
	public Theme copy_to_path(string copy_to) throws Error
	{
		// copy data files
		recursive_copy(path, copy_to);
		
		// create a copy of this theme and change its path
		var theme = new Theme.copy(this);
		theme.path = copy_to;
		return theme;
	}
	
	/**
	 * Loads a Theme's information from JSON
	 *
	 * This function is used to load the defaults and  to load each
	 * extracted theme.
	 *
	 * @param json_path The path to the JSON file.
	 */
	private void load_from_json(string json_path)
	{
		var parser = new Json.Parser();
		try
		{
			parser.load_from_file(json_path);
		}
		catch (Error e)
		{
			error(_("Error loading theme: %s"), e.message);
		}
		
		// create collections
		masters = new Gee.HashMap<string, Gee.Map<string, string>>();
		elements = new Gee.HashMap<string, Gee.Map<string, string>>();
		master_defaults = new Gee.HashMap<string, string>();
		element_defaults = new Gee.HashMap<string, string>();
		
		// get the document's root element
		unowned Json.Node node = parser.get_root();
		if (node == null) return;
		var root = node.get_object();
		if (root == null) return;
		
		// load theme information, if applicable
		if (root.has_member(THEME_TITLE))
			title = root.get_member(THEME_TITLE).get_string();
		
		// find all masters and element overrides
		fill_map(root, MASTERS, masters);
		fill_map(root, ELEMENTS, elements);
		
		if (root.has_member(MASTER_DEF))
			fill_single_map(root.get_object_member(MASTER_DEF),
			                master_defaults);
		if (root.has_member(ELEMENT_DEF))
			fill_single_map(root.get_object_member(ELEMENT_DEF),
			                element_defaults);
	}
	
	/**
	 * Copies all files under Media/ to a new directory.
	 *
	 * @param target The path to copy media files to.
	 */
	public void copy_media(string target) throws GLib.Error
	{
		var origin_path = Path.build_filename(path, MEDIA_PATH);
		
		if (!File.new_for_path(origin_path).query_exists(null)) return;
		
		var target_path = Path.build_filename(target, MEDIA_PATH);
		
		recursive_copy(origin_path, target_path);
	}
	
	/**
	 * Creates a slide from a theme master.
	 *
	 * @param master The string identifier for the master to use. This should be
	 * a string constant of this class (TITLE, CONTENT, etc.)
	 * @param width The width of the slide.
	 * @param height The height of the slide.
	 */
	public Slide? create_slide(string master, int width, int height)
	{
		Slide slide = new Slide();
		
		// set the slide background property
		slide.background_color = Clutter.Color.from_string(master_get(master,
		                                                   BACKGROUND_COLOR));
		
		switch (master)
		{
			case TITLE:
				// create the presentation's title
				int left = element_get(TITLE_TEXT, PAD_LEFT).to_int(),
				    h = element_get(TITLE_TEXT, HEIGHT).to_int();
				slide.add(create_text(
					TITLE_TEXT,
					left,
					height / 2 - h - element_get(TITLE_TEXT, PAD_BOTTOM).to_int(),
					width - left - element_get(TITLE_TEXT, PAD_RIGHT).to_int(),
					h
				));
				
				// create the presentation's author field
				left = element_get(AUTHOR_TEXT, PAD_LEFT).to_int();
				slide.add(create_text(
					AUTHOR_TEXT,
					left,
					height / 2 + element_get(AUTHOR_TEXT, PAD_TOP).to_int(),
					width - left - element_get(AUTHOR_TEXT, PAD_RIGHT).to_int(),
					element_get(AUTHOR_TEXT, HEIGHT).to_int()
				));
				break;
				
			case CONTENT:
				int left = element_get(CONTENT_TEXT, PAD_LEFT).to_int(),
				    top = element_get(CONTENT_TEXT, PAD_TOP).to_int();
				
				slide.add(create_text(
					CONTENT_TEXT,
					left,
					top,
					width - left - element_get(CONTENT_TEXT, PAD_RIGHT).to_int(),
					height - top - element_get(HEADER_TEXT, PAD_BOTTOM).to_int()
				));
				break;
				
			case CONTENT_HEADER:
				// create the slide's header
				int left = element_get(HEADER_TEXT, PAD_LEFT).to_int(),
				    top = element_get(HEADER_TEXT, PAD_TOP).to_int();
				
				slide.add(create_text(
					HEADER_TEXT,
					left,
					top,
					width - left - element_get(HEADER_TEXT, PAD_RIGHT).to_int(),
					element_get(HEADER_TEXT, HEIGHT).to_int()
				));
				
				// create the slide's content
				left = element_get(CONTENT_TEXT, PAD_LEFT).to_int();
				top += element_get(HEADER_TEXT, HEIGHT).to_int() +
				       element_get(HEADER_TEXT, PAD_BOTTOM).to_int() +
				       element_get(CONTENT_TEXT, PAD_TOP).to_int();
				slide.add(create_text(
					CONTENT_TEXT,
					left,
					top,
					width - left - element_get(CONTENT_TEXT, PAD_RIGHT).to_int(),
					height - top - element_get(CONTENT_TEXT, PAD_BOTTOM).to_int()
				));
				break;
			
			case CONTENT_DUAL:
			case CONTENT_DUAL_HEADER:
			case MEDIA:
			case MEDIA_HEADER:
				break;
			default:
				error(_("Invalid master slide title: %s"), master);
				return null;
		}
		
		return slide;
	}
	
	/**
	 * Creates a text element, given an element type and dimensions.
	 */
	private TextElement create_text(string type, int x, int y, int w, int h)
	{
		// error if an improper element type is used
		if (!(type == TITLE_TEXT || type == AUTHOR_TEXT ||
		      type == CONTENT_TEXT || type == HEADER_TEXT))
		{
			error(_("Not a valid text element type: %s"), type);
		}
		
		// otherwise, construct the text element
		var text = new TextElement();
		
		// set text properties
		foreach (var prop in TEXT_PROPS)
		{
			text.set(prop, element_get(type, prop));
		}
		
		// set the color property
		text.color = Clutter.Color.from_string(element_get(type, TEXT_COLOR));
		
		// set size properties
		text.x = x;
		text.y = y;
		text.width = w;
		text.height = h;
		
		// set base properties
		text.identifier = type;
		text.has_been_edited = false;
		text.text = "";
		
		return text;
	}
	
	/**
	 * Retrieves an element property.
	 *
	 * @param element The element name to search for.
	 * @param prop The property name to search for.
	 */
	private string element_get(string element, string prop)
	{
		// try local specifics
		var map = elements.get(element);
		if (map != null)
		{
			var str = map.get(prop);
			if (str != null) return str;
		}
		
		// try local generics
		var str = element_defaults.get(prop);
		if (str != null) return str;
		
		// use default settings
		if (defaults == this)
		{
			error(_("Could not find property %s on element type %s."),
			      prop, element);
		}
		
		return defaults.element_get(element, prop);
	}
	
	/**
	 * Retrieves an master property.
	 *
	 * @param master The master name to search for.
	 * @param prop The property name to search for.
	 */
	private string master_get(string master, string prop)
	{
		// try local specifics
		var map = masters.get(master);
		if (map != null)
		{
			var str = map.get(prop);
			if (str != null) return str;
		}
		
		// try local generics
		var str = master_defaults.get(prop);
		if (str != null) return str;
		
		// use default settings
		if (defaults == this)
		{
			error(_("Could not find property %s on master type %s."),
			      prop, master);
		}
		
		return defaults.master_get(master, prop);
	}
	
	/**
	 * Fills a Gee.Map with style property overrides in the form of more
	 * Gee.Maps.
	 *
	 * @param obj The root object.
	 * @param name The name of the JSON array to use.
	 * @param map The map to fill with submaps.
	 */
	private void fill_map(Json.Object obj, string name,
	                      Gee.Map<string, Gee.Map<string, string>> map)
	{
		if (!obj.has_member(name)) return;
		var sub = obj.get_object_member(name);
		if (sub == null) return;
		
		for (unowned List<string>* i = sub.get_members();
		     i != null; i = i->next)
		{
			// get the current object (an array)
			var curr_obj = sub.get_member(i->data).get_object();
			
			// create a map for the values
			var submap = new Gee.HashMap<string, string>();
		
			// add each override to the map
			fill_single_map(curr_obj, submap);
			
			// add the map to the map of overrides
			map.set(i->data, submap);
		}
	}
	
	/**
	 * Fill a Gee.Map with key/value pairs.
	 *
	 * @param obj The json object to use.
	 * @param map The map to fill.
	 */
	private void fill_single_map(Json.Object obj, Gee.Map<string, string> map)
	{
		for (unowned List<string>* j = obj.get_members();
		     j != null; j = j->next)
		{
			map.set(j->data, obj.get_member(j->data).get_string());
		}
	}
}

