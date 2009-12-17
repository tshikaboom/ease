namespace Ease
{
	public class TextElement : Element
	{
		public string text { get; set; }
		public Clutter.Color color;
		public string font_name { get; set; }
		public uint font_size { get; set; }
		
		public override void print_representation()
		{
			stdout.printf("\t\t\tText Element:\n");
			base.print_representation();
			stdout.printf("\t\t\t\tease_name: %s\n", ease_name);
			stdout.printf("\t\t\t\t     text: %s\n", text);
			stdout.printf("\t\t\t\tfont_name: %s\n", font_name);
			stdout.printf("\t\t\t\tfont_size: %u\n", font_size);
		}
	}
}