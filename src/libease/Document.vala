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

using Xml;

namespace Ease
{
	/**
	 * The internal representation of Ease documents. Contains {@link Slide}s.
	 *
	 * The Ease Document class is generated from XML and writes back to XML
	 * when saved.
	 */
	public class Document : GLib.Object
	{
		public Gee.ArrayList<Slide> slides { get; set; }
		public Theme theme { get; set; }
		public int width { get; set; }
		public int height { get; set; }
		public string path { get; set; }

		/**
		 * Default constructor, used for new documents.
		 * 
		 * Creates a new, empty document with no slides. Used for creating new
		 * documents (which can then add a default slide).
		 */
		public Document()
		{
			slides = new Gee.ArrayList<Slide>();
		}

		/**
		 * Create a document from a file that already exists.
		 * 
		 * Used for loading previously saved files. 
		 *
		 * @param filename The path to the filename.
		 */
		public Document.from_file(string filename)
		{
			this();
			
			path = filename;
			
			var doc = Parser.parse_file(filename + "Document.xml");
			if (doc == null)
			{
				stdout.printf("No Document");
			}
			
			var root = doc->get_root_element();
			if (root == null)
			{
				stdout.printf("No root node");
			}
			else
			{
				for (Xml.Attr* i = root -> properties; i != null; i = i->next)
				{
					switch (i->name)
					{
						case "width":
							this.width = (i->children->content).to_int();
							break;
						case "height":
							this.height = (i->children->content).to_int();
							break;
					}
				}
				parse_xml(root);
			}
			
			delete doc;
		}

		/**
		 * Writes the document to a file (currently, a folder).
		 * 
		 * to_file() uses the Document's "path" property to determine where the
		 * file should be written. Currently, if writing fails, a dialog box
		 * is displayed with the exception.
		 *
		 */
		public void to_file()
		{
			string output = "<?xml version=\"1.0\" ?>\n" +
			                "<document width=\"" + @"$width" + "\" height=\"" + @"$height" + "\">\n" +
			                "\t<slides>\n";
			foreach (var s in slides)
			{
				output += s.to_xml();
			}
			output += "\t</slides>\n</document>\n";

			try
			{
				var file = File.new_for_path(path + "Document.xml");
				var stream = file.replace(null, true, FileCreateFlags.NONE, null);
				var data_stream = new DataOutputStream(stream);
				data_stream.put_string(output, null);
			}
			catch (GLib.Error e)
			{
				var dialog = new Gtk.MessageDialog(null,
				                                   Gtk.DialogFlags.NO_SEPARATOR,
				                                   Gtk.MessageType.ERROR,
				                                   Gtk.ButtonsType.CLOSE,
				                                   "Error saving: %s", e. message);
				dialog.title = "Error Saving";
				dialog.border_width = 5;
				dialog.run();
			}
		}

		/**
		 * Begins the parsing of an XML document.
		 * 
		 * This will be replaced with a JSON file format. 
		 *
		 * @param node The initial XML node to begin with.
		 */
		private void parse_xml(Xml.Node* node)
		{
			for (Xml.Node* iter = node->children; iter != null; iter = iter ->next)
			{
				switch (iter->name)
				{
					case "slides":
						parse_slides(iter);
						break;
				}
			}
		}

		/**
		 * Parses the slides from an XML document.
		 * 
		 * This will be replaced with a JSON file format.
		 *
		 * @param node The slides XML node.
		 */
		private void parse_slides(Xml.Node* node)
		{
			for (Xml.Node* i = node->children; i != null; i = i->next)
			{
				// skip ahead if this isn't a node
				if (i->type != ElementType.ELEMENT_NODE)
				{
					continue;
				}
				
				// create a new slide to be added
				var slide = new Slide(this);
				slide.elements = new Gee.ArrayList<Element>();
				
				// scan the slide's properties
				for (Xml.Attr* j = i->properties; j != null; j = j->next)
				{
					switch (j->name)
					{
						case "transition":
							slide.transition = j->children->content;
							break;
						case "variant":
							slide.variant = j->children->content;
							break;
						case "background_color":
							slide.background_color.from_string(j->children->content);
							break;
						case "background_image":
							slide.background_image = j->children->content;
							break;
					}
				}
						
				// scan the slide's elements
				for (Xml.Node* j = i->children; j != null; j = j->next)
				{					
					if (j->type != ElementType.ELEMENT_NODE)
					{
						continue;
					}

					// build a list of the element's properties
					var list = new Gee.ArrayList<string>();
					for (Xml.Attr* k = j->properties; k != null; k = k->next)
					{
						list.add(k->name);
						list.add(k->children->content);
					}

					// if the element has text, add that as well
					if (j->get_content() != null)
					{
						list.add("text");
						list.add(j-> get_content());
					}
					
					// create an appropriate element
					var element = new Element(slide);
					for (var index = 0; index < list.size; index += 2)
					{
						element.data.set_str(list[index], list[index + 1]);
					}
					
					slide.elements.add(element);
				}
				
				slides.add(slide);
			}
		}
	}
}
