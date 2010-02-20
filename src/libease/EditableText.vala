using libease;

namespace Ease
{
	class EditableText : EditableElement
	{
		private Clutter.Text text;
		
		public EditableText(TextElement e, EditorEmbed em)
		{
			element = e;
			
			// create and format the text actor
			text = new Clutter.Text.full(e.font_name + " " + e.font_size.to_string(),
			                             e.text,
			                             e.color);
			text.line_wrap = true;
			text.line_wrap_mode = Pango.WrapMode.WORD_CHAR;
			this.x = element.x;
			this.y = element.y;
			text.width = element.width;
			text.height = element.height;
			
			this.add_actor(text);
			this.init(em);
		}
		
		public override void set_dimensions(float w, float h, float x, float y)
		{
			text.width = w;
			text.height = h;
			base.set_dimensions(w, h, x, y);
		}
	}
}
