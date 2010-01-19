namespace Ease
{
	abstract class EditableElement : Clutter.Group
	{
		protected Element element { get; set; }
		private DraggableRectangle[] rectangles;
		private Clutter.Group rectangle_group;
		private bool selected;
		private EditorEmbed embed;
		
		protected void init(EditorEmbed e)
		{
			embed = e;
			selected = false;
			
			// user interaction
			reactive = true;
			this.button_press_event.connect(e => {
				if (!selected)
				{
					embed.deselect_elements();
					selected = true;
					create_rectangles();
				}
			});
		}
		
		public virtual void set_dimensions(float w, float h, float x, float y)
		{
			this.width = w;
			element.width = w;
			this.height = h;
			element.height = h;
			this.x = x;
			element.x = x;
			this.y = y;
			element.y = y;
		}
		
		public void deselect()
		{
			selected = false;
			if (rectangle_group != null)
			{
				this.remove_actor(rectangle_group);
			}
		}
		
		protected void create_rectangles()
		{
			// rectangles to resize the element
			rectangles = { new DraggableRectangle(true, true, this, RectanglePosition.TopLeft),
			               new DraggableRectangle(true, true, this, RectanglePosition.TopRight),
			               new DraggableRectangle(false, true, this, RectanglePosition.Top),
			               new DraggableRectangle(true, false, this, RectanglePosition.Left),
			               new DraggableRectangle(true, false, this, RectanglePosition.Right),
			               new DraggableRectangle(true, true, this, RectanglePosition.BottomLeft),
			               new DraggableRectangle(false, true, this, RectanglePosition.BottomRight),
			               new DraggableRectangle(true, true, this, RectanglePosition.Bottom) };
			rectangle_group = new Clutter.Group();
			for (var i = 0; i < 8; i++)
			{
				rectangle_group.add_actor(rectangles[i]);
			}
			this.add_actor(rectangle_group);
		}
		
		public void reposition_rectangles()
		{
			for (var i = 0; i < 8; i++)
			{
				rectangles[i].reposition();
			}
		}
	}
}