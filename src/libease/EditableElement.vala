

namespace Ease
{
	abstract class EditableElement : Clutter.Group
	{
		protected Element element { get; set; }
		private DraggableRectangle[] rectangles;
		private Clutter.Group rectangle_group;
		private bool selected;
		public EditorEmbed embed;
		private Clutter.Timeline double_click;
		private bool clicked;
		private bool mouse_down;
		private bool dragging;
		private float offset_x;
		private float offset_y;
		
		protected void init(EditorEmbed e)
		{
			embed = e;
			selected = false;
			clicked = false;
			dragging = false;
			
			// user interaction
			reactive = true;
			this.button_press_event.connect(e => {
				if (!selected)
				{
					embed.deselect_elements();
					selected = true;
				}
				offset_x = e.button.x;
				offset_y = e.button.y;
				mouse_down = true;
				Clutter.grab_pointer(this);
				double_click = new Clutter.Timeline(Gtk.Settings.get_default().gtk_double_click_time);
				double_click.start();
				double_click.completed.connect(e => {
					clicked = false;
					if (mouse_down) // the mouse was not released between clicks
					{
						dragging = true;
					}
				});
				clicked = true;
				create_rectangles();
				return false;
			});
			this.button_release_event.connect(e => {
				mouse_down = false;
				dragging = false;
				Clutter.ungrab_pointer();
				return false;
			});
			this.motion_event.connect(e => {
				if (dragging)
				{
					this.x = this.x + e.motion.x - offset_x;
					this.y = this.y + e.motion.y - offset_y;
					element.x = this.x;
					element.y = this.y;
				}
				return false;
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
