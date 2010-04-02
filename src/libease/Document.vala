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
	public class Document : GLib.Object
	{
		public Gee.ArrayList<Slide> slides { get; set; }
		public Theme theme { get; set; }
		public int width { get; set; }
		public int height { get; set; }
		public string path { get; set; }
		
		public Document()
		{
			slides = new Gee.ArrayList<Slide>();
		}
		
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
			
			var file = File.new_for_path(path + "Document.xml");
			var stream = file.replace(null, true, FileCreateFlags.NONE, null);
			var data_stream = new DataOutputStream(stream);
			data_stream.put_string(output, null);
		}
		
		public void print_representation()
		{
			stdout.printf("Ease Document with %i width and %i height:\n", width, height);
			stdout.printf("\t%i slides:\n", slides.size);
			for (var i = 0; i < slides.size; i++)
			{
				stdout.printf("\t\tSlide with %s transition and %i elements:\n", slides.get(i).transition, slides.get(i).elements.size);
				for (var j = 0; j < slides.get(i).elements.size; j++)
				{
					slides.get(i).elements.get(j).print_representation();
				}
			}
		}
		
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
															
					var map = new Gee.HashMap<string, string>(GLib.str_hash, GLib.str_equal);
					
					for (Xml.Attr* k = j->properties; k != null; k = k->next)
					{
						map.set(k->name, k->children->content);
					}
					
					if (j->get_content() != null)
					{
						map.set("text", j-> get_content());
					}
					
					// create an appropriate element
					Element element;
					switch (map.get("type"))
					{
						case "text":
							element = new TextElement.from_map(map, slide);
							break;
						case "image":
							element = new ImageElement.from_map(map, slide);
							break;
						default:
							stdout.printf("Wrong Element Type: %s", map.get("type"));
							return;
					}
					slide.elements.add(element);
				}
				
				slides.add(slide);
			}
		}
	}
}