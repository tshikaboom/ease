namespace Ease
{
	public class TextElement : Element
	{
		public string text { get; set; }
		public Clutter.Color color;
		public string font_name { get; set; }
		public Pango.Style font_style { get; set; }
		public Pango.Variant font_variant { get; set; }
		public Pango.Weight font_weight;
		public Pango.Alignment text_align { get; set; }
		public int font_size { get; set; }
		
		public TextElement.from_map(Gee.Map<string, string> map, Slide owner)
		{
			base.from_map(map, owner);
			element_type = "text";
			text = map.get("text");
			color.from_string(map.get("color"));
			
			// determine font properties
			font_name = map.get("font_name");
			font_size = map.get("font_size").to_int();
			
			font_variant = map.get("font_variant") == "Normal" ?
			               Pango.Variant.NORMAL:
			               Pango.Variant.SMALL_CAPS;
			
			switch (map.get("font_style"))
			{
				case "Oblique":
					font_style = Pango.Style.OBLIQUE;
					break;
				case "Italic":
					font_style = Pango.Style.ITALIC;
					break;
				default:
					font_style = Pango.Style.NORMAL;
					break;
			}
			
			switch (map.get("align"))
			{
				case "right":
					text_align = Pango.Alignment.RIGHT;
					break;
				case "center":
					text_align = Pango.Alignment.CENTER;
					break;
				default:
					text_align = Pango.Alignment.LEFT;
					break;
			}
			
			font_weight = (Pango.Weight)(map.get("font_weight").to_int());
		}
		
		public override string to_xml()
		{
			string pango = "";
			
			switch (font_style)
			{
				case Pango.Style.OBLIQUE:
					pango += "style=\"Oblique\" ";
					break;
				case Pango.Style.ITALIC:
					pango += "style=\"Italic\" ";
					break;
				case Pango.Style.NORMAL:
					pango += "style\"Normal\" ";
					break;
			}
			
			switch (text_align)
			{
				case Pango.Alignment.LEFT:
					pango += "align=\"left\" ";
					break;
				case Pango.Alignment.CENTER:
					pango += "style=\"center\" ";
					break;
				case Pango.Alignment.RIGHT:
					pango += "style\"right\" ";
					break;
			}
			
			pango += "font_weight=\"" + @"$((int)(font_weight))" + "\" ";
			
			pango += "font_variant=\"" +
			         (font_variant == Pango.Variant.NORMAL ? "Normal" : "Small Caps") +
			         "\" ";
			
			return "\t\t\t\t<element type=\"text\" " +
			       "font_name=\"" + font_name + "\" " +
			       "font_size=\"" + @"$font_size" + "\" " +
			       "color=\"" + color.to_string() + "\" " +
			       pango +
			       xml_base() +
			       ">" +
			       text +
			       "</element>\n";
		}
		
		public override void print_representation()
		{
			stdout.printf("\t\t\tText Element:\n");
			base.print_representation();
			stdout.printf("\t\t\t\tease_name: %s\n", ease_name);
			stdout.printf("\t\t\t\t     text: %s\n", text);
			stdout.printf("\t\t\t\tfont_name: %s\n", font_name);
			stdout.printf("\t\t\t\tfont_size: %u\n", font_size);
		}
		
		public override Clutter.Actor presentation_actor() throws GLib.Error
		{
			var actor = new Clutter.Text();
			set_actor_base_properties(actor);
			actor.use_markup = true;
			actor.line_wrap = true;
			actor.line_wrap_mode = Pango.WrapMode.WORD_CHAR;
			actor.color = color;
			actor.set_markup(text);
			
			// create the font name
			var desc = new Pango.FontDescription();
			desc.set_family(font_name);
			desc.set_weight(font_weight);
			desc.set_variant(font_variant);
			desc.set_size(font_size * Pango.SCALE);
			actor.font_name = desc.to_string();
			actor.set_line_alignment(text_align);
			
			return actor;
		}
	}
}
