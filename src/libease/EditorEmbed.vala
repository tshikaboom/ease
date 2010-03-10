

namespace Ease
{
	public class EditorEmbed : ScrollableEmbed
	{
		private Clutter.Group group;
		private Clutter.Actor background;
		private Document document;
		public float zoom;
		public bool zoom_fit;
		private Gee.ArrayList<EditableElement> elements;
		
		public EditorEmbed(Document d)
		{
			base(true);
			
			document = d;
			this.set_size_request(320, 240);
			var color = Clutter.Color();
			color.from_string("Gray");
			get_stage().set_color(color);
			zoom = 1;
			zoom_fit = false;
			
			this.size_allocate.connect(() => {
				if (zoom_fit)
				{
					zoom = get_stage().width / get_stage().height > (float)document.width / document.height ?
					       get_stage().height / document.height :
					       get_stage().width / document.width;
					reposition_group();
				}
				else
				{
					reposition_group();
				}
			});
		}
		
		public void set_zoom(float z)
		{
			zoom = z / 100;
			reposition_group();
		}
		
		public void set_slide(Slide slide)
		{
			// clean up the previous slide
			if (group != null)
			{
				get_stage().remove_actor(group);
			}
			group = new Clutter.Group();
			
			// create the background for the new slide
			if (slide.background_image != null)
			{
				background = new Clutter.Texture.from_file(document.path + slide.background_image);
				background.width = document.width;
				background.height = document.height;
			}
			else
			{
				background = new Clutter.Rectangle();
				((Clutter.Rectangle)background).set_color(slide.background_color);
				background.width = document.width;
				background.height = document.height;
			}
			group.add_actor(background);
			
			// load slide elements
			elements = new Gee.ArrayList<EditableElement>();
			foreach (var e in slide.elements)
			{
				EditableElement element;
				switch (e.element_type)
				{
					case "text":
						element = new EditableText((TextElement)e, this);
						elements.add(element);
						group.add_actor(element);
						break;
					case "image":
						element = new EditableImage((ImageElement)e, this);
						elements.add(element);
						group.add_actor(element);
						break;
				}
			}
			get_stage().add_actor(group);
			reposition_group();
		}
		
		public void reposition_group()
		{
			group.set_scale_full(zoom, zoom, 0, 0);
			group.set_position(get_stage().width / 2, get_stage().height / 2);
			group.set_anchor_point(group.width / 2, group.height / 2);
		}
		
		public float group_x()
		{
			return group.x - group.width / 2;
		}
		
		public float group_y()
		{
			return group.y - group.height / 2;
		}
		
		public void deselect_elements()
		{
			foreach (var e in elements)
			{
				e.deselect();
			}
		}
	}
}
