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
	public class Handle : Clutter.Group
	{
		// the graphical element of the rectangle
		private Clutter.Rectangle rectangle;
		
		// the position of this rectangle
		private HandlePosition position;

		// the offset of the pointer, so things don't jump
		private int pointer_offset_x;
		private int pointer_offset_y;
		
		// constants
		public static const float SIZE = 10;
		
		public Handle(HandlePosition pos)
		{
			// set the rectangle's position
			position = pos;

			// make the actual rectangle
			rectangle = new Clutter.Rectangle();

			// set the rectangle's color
			rectangle.color = {0, 0, 0, 255};

			// set the rectangle's border
			rectangle.border_width = 2;
			rectangle.border_color = {255, 255, 255, 255};

			// set the rectangle's size
			rectangle.width = SIZE;
			rectangle.height = SIZE;
			set_anchor_point(SIZE / 2, SIZE / 2);

			// add the rectangle
			add_actor(rectangle);
			
			reactive = true;
		}
		
		public void reposition(Clutter.Actor selection)
		{
			switch (position)
			{
				case HandlePosition.TOP_LEFT:
					x = selection.x;
					y = selection.y;
					break;
					
				case HandlePosition.TOP_RIGHT:
					x = selection.x + selection.width;
					y = selection.y;
					break;
					
				case HandlePosition.TOP:
					x = selection.x + selection.width / 2;
					y = selection.y;
					break;
					
				case HandlePosition.LEFT:
					x = selection.x;
					y = selection.y + selection.height / 2;
					break;
					
				case HandlePosition.RIGHT:
					x = selection.x + selection.width;
					y = selection.y + selection.height / 2;
					break;
					
				case HandlePosition.BOTTOM_LEFT:
					x = selection.x;
					y = selection.y + selection.height;
					break;
					
				case HandlePosition.BOTTOM_RIGHT:
					x = selection.x + selection.width;
					y = selection.y + selection.height;
					break;
					
				case HandlePosition.BOTTOM:
					x = selection.x + selection.width / 2;
					y = selection.y + selection.height;
					break;
			}
		}
	}
}
