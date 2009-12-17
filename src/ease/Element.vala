namespace Ease
{
	public abstract class Element : GLib.Object
	{
		public string ease_name { get; set; }
		public float x { get; set; }
		public float y { get; set; }
		public float width { get; set; }
		public float height { get; set; }
		
		public virtual void print_representation()
		{
			stdout.printf("\t\t\t\tease_name: %s\n", ease_name);
			stdout.printf("\t\t\t\t        x: %f\n", x);
			stdout.printf("\t\t\t\t        y: %f\n", y);
			stdout.printf("\t\t\t\t    width: %f\n", width);
			stdout.printf("\t\t\t\t   height: %f\n", height);
		}
	}
}