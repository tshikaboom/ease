namespace Ease
{
	public class Slide
	{
		public Gee.ArrayList<Element> elements { get; set; }
		public string transition { get; set; }
		public string variant { get; set; }
		public Clutter.Color background_color;
		public string background_image { get; set; }
		public Document parent { get; set; }
		
		public Slide(Document owner)
		{
			parent = owner;
		}
	}
}
