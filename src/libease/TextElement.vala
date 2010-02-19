namespace libease
{
	public class TextElement : Element
	{
		public string text { get; set; }
		public Clutter.Color color;
		public string font_name { get; set; }
		public Pango.Style font_style { get; set; }
		public Pango.Variant font_variant { get; set; }
		public Pango.Weight font_weight;
		public int font_size { get; set; }
		
		public TextElement.from_map(Gee.Map<string, string> map, Slide owner)
		{
			base.from_map(map, owner);
			this.element_type = "text";
			this.text = map.get("text");
			this.color.from_string(map.get("color"));
			
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
			
			font_weight = (Pango.Weight)(map.get("font_weight").to_int());
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
			actor.color = this.color;
			actor.set_markup(this.text);
			
			// create the font name
			var desc = new Pango.FontDescription();
			desc.set_family(this.font_name);
			desc.set_weight(this.font_weight);
			desc.set_variant(this.font_variant);
			desc.set_size(font_size * Pango.SCALE);
			actor.font_name = desc.to_string();
			
			return actor;
		}
	}
}
