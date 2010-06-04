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
 * Parses JSON files to load Ease {@link Document}s
 */
public static class Ease.JSONParser
{
	private const int ARCHIVE_BUFFER = 4096;
	
	/**
	 * Parses a document JSON file, creating a {@link Document}.
	 *
	 * @param filename The filename of the {@link Document}
	 */
	public static Document document(string filename) throws GLib.Error
	{
		var document = new Document();
		document.path = filename;
	
		var parser = new Json.Parser();
		
		// attempt to load the file
		parser.load_from_file(Path.build_path("/", filename, "Document.json"));
		
		// grab the root object
		var root = parser.get_root().get_object();
		
		// set document properties
		document.width = (int)root.get_string_member("width").to_int();
		document.height = (int)root.get_string_member("height").to_int();
		
		// add all slides
		var slides = root.get_array_member("slides");
		
		for (var i = 0; i < slides.get_length(); i++)
		{
			var node = slides.get_object_element(i);
			document.add_slide(document.length, parse_slide(node));
		}
		
		return document;
	}
	
	/**
	 * Parses a theme JSON file, creating a {@link Theme}.
	 *
	 * @param filename The path to the {@link Theme}
	 */
	public static Theme theme(string filename) throws GLib.Error
	{
		// initialize the .easetheme archive
		var archive = new Archive.Read();
		
		// automatically detect archive type
		archive.support_compression_all();
		archive.support_format_all();
		
		// open the archive
		archive.open_filename(filename, ARCHIVE_BUFFER);
		
		// extract the archive
		string path = Temp.request();
		
		weak Archive.Entry entry;
		while (archive.next_header(out entry) == Archive.Result.OK)
		{
			var fpath = Path.build_path("/", path, entry.pathname());
			var file = GLib.File.new_for_path(fpath);
			if (Posix.S_ISDIR(entry.mode()))
			{
				file.make_directory_with_parents(null);
			}
			else
			{
				file.create(FileCreateFlags.REPLACE_DESTINATION, null);
				int fd = Posix.open(fpath, Posix.O_WRONLY, 0644);
				archive.read_data_into_fd(fd);
				Posix.close(fd);
			}
		}
		
		var theme = new Theme();
		theme.path = path;
	
		var parser = new Json.Parser();
		
		// attempt to load the file
		parser.load_from_file(Path.build_path("/", path, "Theme.json"));
		
		// grab the root object
		var root = parser.get_root().get_object();
		
		// set theme properties
		theme.title = root.get_string_member("title");
		
		// add all slides
		var slides = root.get_array_member("slides");
		
		for (var i = 0; i < slides.get_length(); i++)
		{
			var node = slides.get_object_element(i);
			theme.add_slide(theme.length, parse_slide(node));
		}
		
		return theme;
	}
	
	private static Slide parse_slide(Json.Object obj)
	{
		var slide = new Slide();
		
		// read the slide's transition properties
		slide.transition =
			(TransitionType)obj.get_string_member("transition").to_int();
			
		slide.variant =
			(TransitionVariant)obj.get_string_member("variant").to_int();
			
		slide.transition_time =
			obj.get_string_member("transition_time").to_double();
			
		slide.automatically_advance = 
			obj.get_string_member("automatically_advance").to_bool();
			
		slide.advance_delay =
			obj.get_string_member("advance_delay").to_double();
		
		slide.title = obj.get_string_member("title");
		
		// read the slide's background properties
		if (obj.has_member("background_image"))
		{
			slide.background_image = obj.get_string_member("background_image");
		}
		else
		{
			slide.background_color.red =
				(uchar)(obj.get_string_member("red").to_int());
			
			slide.background_color.green =
				(uchar)(obj.get_string_member("green").to_int());
			
			slide.background_color.blue =
				(uchar)(obj.get_string_member("blue").to_int());
			
			slide.background_color.alpha = 255;
		}
		
		// parse the elements
		var elements = obj.get_array_member("elements");
		
		for (var i = 0; i < elements.get_length(); i++)
		{
			var node = elements.get_object_element(i);
			slide.add_element(slide.count, parse_element(node));
		}
		
		return slide;
	}
	
	private static Element parse_element(Json.Object obj)
	{
		var element = new Element();
		
		// set the Element's properties
		for (unowned List<string>* itr = obj.get_members();
		     itr != null; itr = itr->next)
		{
			string name = itr->data;
			element.data.set(name, obj.get_member(name).get_string());
		}
		
		return element;
	}
	
	/**
	 * Saves a {@link Document} to JSON.
	 *
	 * @param document The {@link Document} to be saved.
	 */
	public static void document_write(Document document) throws GLib.Error
	{
		var root = new Json.Node(Json.NodeType.OBJECT);
		var obj = new Json.Object();
		
		// set basic document properties
		obj.set_string_member("width", document.width.to_string());
		obj.set_string_member("height", document.height.to_string());
		
		// add the document's slides
		var slides = new Json.Array();
		foreach (var s in document.slides)
		{
			slides.add_element(document_write_slide(s));
		}
		obj.set_array_member("slides", slides);
		
		// set the root object
		root.set_object(obj);
		
		// write to file
		var generator = new Json.Generator();
		generator.set_root(root);
		generator.pretty = true;
		generator.to_file(Path.build_path("/", document.path, "Document.json"));
	}
	
	private static Json.Node document_write_slide(Slide slide)
	{
		var node = new Json.Node(Json.NodeType.OBJECT);
		var obj = new Json.Object();
		
		// write the slide's transition properties
		obj.set_string_member("transition",
		                      ((int)slide.transition).to_string());
		obj.set_string_member("variant",
		                      ((int)slide.variant).to_string());
		obj.set_string_member("transition_time",
		                      slide.transition_time.to_string());
		obj.set_string_member("automatically_advance",
		                      slide.automatically_advance.to_string());
		obj.set_string_member("advance_delay",
		                      slide.advance_delay.to_string());
		obj.set_string_member("title", slide.title);
		
		// write the slide's background properties
		if (slide.background_image != null)
		{
			obj.set_string_member("background_image", slide.background_image);
		}
		else
		{
			obj.set_string_member("red",
			                      slide.background_color.red.to_string());
			obj.set_string_member("green",
			                      slide.background_color.green.to_string());
			obj.set_string_member("blue",
			                      slide.background_color.blue.to_string());
		}
		
		// add the slide's elements
		var elements = new Json.Array();
		foreach (var e in slide.elements)
		{
			elements.add_element(e.data.to_json());
		}

		obj.set_array_member("elements", elements);
		
		node.set_object(obj);
		return node;
	}
}

