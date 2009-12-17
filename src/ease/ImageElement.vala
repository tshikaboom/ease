namespace Ease
{
	public class ImageElement : Element
	{
		public string filename { get; set; }
		public float scale_x { get; set; }
		public float scale_y { get; set; }
		
		public override Clutter.Actor presentation_actor() throws GLib.Error
		{
			try
			{
				var actor = new Clutter.Texture.from_file(filename);
				set_actor_base_properties(actor);
				return actor;
			}
			catch (GLib.Error e)
			{
				throw e;
			}
		}
	}
}