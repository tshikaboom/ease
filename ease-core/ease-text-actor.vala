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

/**
 * {@link Actor} for blocks of text
 * 
 * TextActor uses {@link Clutter.Text} for rendering.
 */
public class Ease.TextActor : Actor
{
	/**
	 * The opacity of the selection highlight.
	 */
	private const uchar SELECTION_ALPHA = 200;
	
	/**
	 * {@link UndoAction} for an edit.
	 */
	private UndoAction undo_action;
	
	/**
	 * The CairoTexture that is rendered onto.
	 */
	private Clutter.CairoTexture texture;
	
	/**
	 * The editing cursor.
	 */
	private Clutter.Rectangle cursor;
	
	/**
	 * The cursor's animation timeline.
	 */
	private Clutter.Timeline cursor_timeline;
	
	/**
	 * The index of the cursor.
	 */
	private int cursor_index = 0;

	/**
	 * Instantiates a new TextActor from an Element.
	 * 
	 * TextActor uses {@link Clutter.Text} for rendering.
	 *
	 * @param e The represented element.
	 * @param c The context of this Actor (Presentation, Sidebar, Editor)
	 */
	public TextActor(TextElement e, ActorContext c)
	{
		base(e, c);
		
		// create cursor
		cursor = new Clutter.Rectangle();
		cursor.color = { 255, 255, 255, 255 };
		cursor.border_width = 1;
		cursor.border_color = { 0, 0, 0, 255 };
		cursor.width = 4;
		
		texture = new Clutter.CairoTexture((uint)e.width, (uint)e.height);
		contents = texture;
		
		// automatically render when the size of the texture changes
		texture.allocation_changed.connect(() => {
			texture.clear();
			render_text();
		});
		
		add_actor(contents);
		contents.width = e.width;
		contents.height = e.height;
		x = e.x;
		y = e.y;
		
		// position the cursor when the actor is resized
		contents.notify["width"].connect(() => position_cursor());
		contents.notify["height"].connect(() => position_cursor());
	}
	
	public override void edit(Gtk.Widget sender, float mouse_x, float mouse_y)
	{
		int trailing = -1;
		if (!(element as TextElement).text.layout.xy_to_index((int)mouse_x,
		                                                      (int)mouse_y,
		                                                      ref cursor_index,
		                                                      ref trailing))
		{
			cursor_index =
				(int)(element as TextElement).text.layout.get_text().length;
		}
		
		debug("Editing text, cursor index is %i", cursor_index);
		
		// add and animate the cursor
		add_actor(cursor);
		position_cursor();
		cursor.opacity = 0;
		cursor_timeline = new Clutter.Timeline(
			(uint)(Gtk.Settings.get_default().gtk_cursor_blink_time / 2));
		cursor_timeline.completed.connect(on_cursor_timeline_completed);
		on_cursor_timeline_completed(cursor_timeline);
		
		// render the text, to remove the default text if applicable
		render_text();
	}
	
	public override bool key_event(Gtk.Widget sender, Gdk.EventKey event)
	{
		if (event.type == Gdk.EventType.KEY_PRESS)
		{
			var text = (element as TextElement).text;
			
			// handle special keys
			switch (event.keyval)
			{
				case Key.BACKSPACE:
					if (cursor_index > 0)
					{
						text.delete(cursor_index - 1);
						cursor_index--;
					}
					break;
				
				case Key.LEFT:
					cursor_index = int.max(cursor_index - 1, 0);
					cursor.opacity = 255;
					cursor_timeline.rewind();
					break;
				
				case Key.RIGHT:
					cursor_index = int.min(cursor_index + 1,
					                       (int)text.layout.get_text().length);
					cursor.opacity = 255;
					cursor_timeline.rewind();
					break;
				
				default: {
					unichar key = Gdk.keyval_to_unicode(event.keyval);
					if (key != 0)
					{
						text.insert(key.to_string(), cursor_index);
						cursor_index++;
					}
					break;
				}
			}
			
			render_text();
			position_cursor();
			debug("Cursor index is %i", cursor_index);
		}
		
		return true;
	}
	
	private override void end_edit(Gtk.Widget sender)
	{
		// remove the cursor and stop its animation
		remove_actor(cursor);
		render_text();
	}
	
	/**
	 * Moves the cursor to the specified index.
	 */
	private void position_cursor()
	{
		// get the position
		Pango.Rectangle rect;
		(element as TextElement).text.layout.index_to_pos(cursor_index,
		                                                  out rect);
		
		// move the cursor
		cursor.x = rect.x / Pango.SCALE + 3;
		cursor.y = rect.y / Pango.SCALE;
		cursor.height = rect.height/ Pango.SCALE;
	}
	
	/**
	 * Signal handler for cursor blinking.
	 */
	private void on_cursor_timeline_completed(Clutter.Timeline timeline)
	{
		// rewind the timeline and fade in the other direction
		timeline.rewind();
		cursor.opacity = cursor.opacity == 0 ? 255 : 0;
		timeline.start();
	}
	
	/**
	 * Renders the TextElement's text to the CairoTexture.
	 */
	private void render_text()
	{
		texture.clear();
		texture.set_surface_size((uint)texture.width, (uint)texture.height);
		var cr = texture.create();
		(element as TextElement).text.render(cr, !editing,
		                                     (int)texture.width,
		                                     (int)texture.height);
	}
}

