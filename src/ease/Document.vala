using GLib;
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
					
					// create an appropriate element
					Element element;
					switch (map.get("type"))
					{
						case "text":
							element = new TextElement();
							((TextElement)element).text = map.get("text");
							((TextElement)element).font_name = map.get("font_name");
							((TextElement)element).font_size = map.get("font_size").to_int();
							((TextElement)element).color.from_string(map.get("color"));
							break;
						case "image":
							element = new ImageElement();
							((ImageElement)element).filename = map.get("filename");
							((ImageElement)element).scale_x = (float)map.get("scale_x").to_double();
							((ImageElement)element).scale_y = (float)map.get("scale_y").to_double();
							break;
						default:
							stdout.printf("Wrong Element Type: %s", map.get("type"));
							return;
					}
					
					// set the common Element features
					element.ease_name = map.get("ease_name");
					element.x = map.get("x").to_int();
					element.y = map.get("y").to_int();
					element.width = map.get("width").to_int();
					element.height = map.get("height").to_int();
					element.parent = slide;
					slide.elements.add(element);
				}
				
				slides.add(slide);
			}
		}
	}
}