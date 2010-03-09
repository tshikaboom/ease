namespace Ease
{
	public class ImageElement : Element
	{
		public string filename { get; set; }
		public float scale_x { get; set; }
		public float scale_y { get; set; }
		
		public ImageElement.from_map(Gee.Map<string, string> map, Slide owner)
		{
			base.from_map(map, owner);
			this.element_type = "image";
			this.filename = map.get("filename");
			this.scale_x = (float)map.get("scale_x").to_double();
			this.scale_y = (float)map.get("scale_y").to_double();
		}
		
		public override Clutter.Actor presentation_actor() throws GLib.Error
		{
			try
			{
				var actor = new Clutter.Texture.from_file(parent.parent.path + filename);
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
