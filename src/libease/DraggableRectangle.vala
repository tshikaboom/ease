/*  Ease, a GTK presentation application
    Copyright (C) 2010 Nate Stedman

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

namespace Ease
{
	public class DraggableRectangle : Clutter.Group
	{
		// the graphical element of the rectangle
		private Clutter.Rectangle rectangle;
		
		// the position of this rectangle
		private RectanglePosition position;

		// the offset of the pointer, so things don't jump
		private int pointer_offset_x;
		private int pointer_offset_y;
		
		// constants
		public static const float SIZE = 10;
		
		public DraggableRectangle(RectanglePosition pos)
		{
			// set the rectangle's position
			position = pos;

			// make the actual rectangle
			rectangle = new Clutter.Rectangle();

			// set the rectangle's color
			Clutter.Color color = Clutter.Color();
			color.from_string("Black");
			rectangle.color = color;

			// set the rectangle's border
			rectangle.border_width = 1;
			color.from_string("White");
			rectangle.border_color = color;

			// set the rectangle's size
			rectangle.width = SIZE;
			rectangle.height = SIZE;
			set_anchor_point(SIZE / 2, SIZE / 2);

			// add the rectangle
			add_actor(rectangle);
			
			reactive = true;
			button_press_event.connect(e => {
				//if (e.get_button() == 1)
				{
					start_drag();
				}
				return false;
			});
			
			button_release_event.connect(e => {
				//if (e.get_button() == 1)
				{
					stop_drag();
				}
				return false;
			});
			
			motion_event.connect(e => {
				if (Clutter.get_pointer_grab() == this)
				{
					drag(e.motion);
				}
				return false;
			});
			
			reposition();
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
			
		}
		
		public void reposition()
		{
			switch (position)
			{
				case RectanglePosition.TopLeft:
					break;
				case RectanglePosition.TopRight:
					break;
				case RectanglePosition.Top:
					break;
				case RectanglePosition.Left:
					break;
				case RectanglePosition.Right:
					break;
				case RectanglePosition.BottomLeft:
					break;
				case RectanglePosition.BottomRight:
					break;
				case RectanglePosition.Bottom:
					break;
			}
		}
	}
}
