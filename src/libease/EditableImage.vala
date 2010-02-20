using libease;

namespace Ease
{
	class EditableImage : EditableElement
	{
		private Clutter.Texture texture;
		
		public EditableImage(ImageElement e, EditorEmbed em)
		{
			element = e;
			
			// create and format the texture actor
			texture = new Clutter.Texture.from_file(e.parent.parent.path + e.filename);
			this.x = element.x;
			this.y = element.y;
			texture.width = element.width;
			texture.height = element.height;
			
			this.add_actor(texture);
			this.init(em);
		}
		
		public override void set_dimensions(float w, float h, float x, float y)
		{
			texture.width = w;
			texture.height = h;
			base.set_dimensions(w, h, x, y);
		}
	}
}
