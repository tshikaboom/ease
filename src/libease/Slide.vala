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
		
		public string to_xml()
		{
			string output = "\t\t<slide " +
			                "transition=\"" + transition + "\" " +
			                "variant=\"" + variant + "\" " +
			                (background_image != null ?
			                                        ("background_image=\"" + background_image + "\" ") :
			                                        ("background_color=\"" + background_color.to_string() + "\" ")) +
			                ">\n";
			
			foreach (var e in elements)
			{
				output += e.to_xml();
			}
			
			output += "</slide>\n";
			return output;
		}
	}
}
