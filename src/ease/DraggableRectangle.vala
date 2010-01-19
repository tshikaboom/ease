namespace Ease
{
	class DraggableRectangle : Clutter.Group
	{
		private Clutter.Rectangle rectangle;
		public bool drag_vertical { get; set; }
		public bool drag_horizontal { get; set; }
		private EditableElement parent;
		private RectanglePosition position;
		private int pointer_offset_x;
		private int pointer_offset_y;
		
		// constants
		public static const float SIZE = 10;
		
		public DraggableRectangle(bool vertical, bool horizontal, EditableElement owner, RectanglePosition pos)
		{
			drag_vertical = vertical;
			drag_horizontal = horizontal;
			position = pos;
			parent = owner;
			
			rectangle = new Clutter.Rectangle();
			Clutter.Color color = Clutter.Color();
			color.from_string("Black");
			rectangle.color = color;
			//rectangle.has_border = true;
			rectangle.border_width = 1;
			color.from_string("White");
			rectangle.border_color = color;
			rectangle.width = SIZE;
			rectangle.height = SIZE;
			rectangle.x = -SIZE / 2;
			rectangle.y = -SIZE / 2;
			this.add_actor(rectangle);
			
			this.reactive = true;
			this.button_press_event.connect(e => {
				start_drag();
			});
			this.button_release_event.connect(e => {
				//if (e.get_button() == 1)
				{
					stop_drag();
				}
			});
			this.motion_event.connect(e => {
				if (Clutter.get_pointer_grab() == this)
				{
					this.drag(e.motion);
				}
			});
			
			this.reposition();
		}
		
		public void start_drag()
		{
			Clutter.grab_pointer(this);
			
			//TODO: actually set the offsets
			pointer_offset_x = 0;
			pointer_offset_y = 0;
		}
		
		private void stop_drag()
		{
			Clutter.ungrab_pointer();
		}
		
		private void drag(Clutter.MotionEvent m)
		{
			switch (position)
			{
				case RectanglePosition.TopLeft:
					parent.set_dimensions(parent.width + parent.x - m.x,
					                      parent.height + parent.y - m.y,
					                      m.x,
					                      m.y);
					break;
			}
			parent.reposition_rectangles();
		}
		
		public void reposition()
		{
			switch (position)
			{
				case RectanglePosition.TopLeft:
					this.x = 0;
					this.y = 0;
					break;
				case RectanglePosition.TopRight:
					this.x = parent.width;
					this.y = 0;
					break;
				case RectanglePosition.Top:
					this.x = parent.width / 2;
					this.y = 0;
					break;
				case RectanglePosition.Left:
					this.x = 0;
					this.y = parent.height / 2;
					break;
				case RectanglePosition.Right:
					this.x = parent.width;
					this.y = parent.height / 2;
					break;
				case RectanglePosition.BottomLeft:
					this.x = 0;
					this.y = parent.height;
					break;
				case RectanglePosition.BottomRight:
					this.x = parent.width;
					this.y = parent.height;
					break;
				case RectanglePosition.Bottom:
					this.x = parent.width / 2;
					this.y = parent.height;
					break;
			}
		}
	}
}