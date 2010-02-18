namespace libease
{
	public class TextElement : Element
	{
		public string text { get; set; }
		public Clutter.Color color;
		public string font_name { get; set; }
		public uint font_size { get; set; }
		
		public TextElement.from_map(Gee.Map<string, string> map, Slide owner)
		{
			base.from_map(map, owner);
			this.element_type = "text";
			this.text = map.get("text");
			this.font_name = map.get("font_name");
			this.font_size = map.get("font_size").to_int();
			this.color.from_string(map.get("color"));
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
			actor.font_name = this.font_name + " " + this.font_size.to_string();
			return actor;
		}
	}
}
