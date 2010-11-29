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
	private const int SCALE = Pango.SCALE;
	
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
	 * The other end of the selection (the first one being {@link cursor_index}.
	 */
	private int selection_index = 0;

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
		int trailing = 0;
		var layout = (element as TextElement).text.layout;
		if (!layout.xy_to_index((int)mouse_x * Pango.SCALE,
		                        (int)mouse_y * Pango.SCALE,
		                        out cursor_index, out trailing))
		{
			debug("Click was not inside element (%f, %f)", mouse_x, mouse_y);
			cursor_index =
				(int)(element as TextElement).text.layout.get_text().length;
		}
		cursor_index += trailing;
		selection_index = cursor_index;
		
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
	
	private override void end_edit(Gtk.Widget sender)
	{
		// remove the cursor and stop its animation
		remove_actor(cursor);
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
						selection_index = cursor_index;
						cursor.opacity = 255;
						cursor_timeline.rewind();
					}
					break;
				
				case Key.DELETE:
					if (cursor_index < text.layout.get_text().length)
					{
						text.delete(cursor_index);
						cursor.opacity = 255;
						cursor_timeline.rewind();
					}
					break;
				
				case Key.DELETE:
					if (cursor_index < text.layout.get_text().length)
					{
						text.delete(cursor_index);
						cursor.opacity = 255;
						cursor_timeline.rewind();
					}
					break;
				
				case Key.LEFT:
					cursor_index = int.max(cursor_index - 1, 0);
					selection_index = cursor_index;
					cursor.opacity = 255;
					cursor_timeline.rewind();
					break;
				
				case Key.RIGHT:
					cursor_index = int.min(cursor_index + 1,
					                       (int)text.layout.get_text().length);
					selection_index = cursor_index;
					cursor.opacity = 255;
					cursor_timeline.rewind();
					break;
				
				case Key.ENTER:
					text.insert("\n", cursor_index);
					cursor_index++;
					selection_index = cursor_index;
					cursor.opacity = 255;
					cursor_timeline.rewind();
					break;
				
				default: {
					unichar key = Gdk.keyval_to_unicode(event.keyval);
					if (key != 0)
					{
						text.insert(key.to_string(), cursor_index);
						cursor_index++;
						selection_index = cursor_index;
						cursor.opacity = 255;
						cursor_timeline.rewind();
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
	
	private override bool clicked_event(Clutter.Actor self,
	                                    Clutter.ButtonEvent event,
	                                    float mouse_x, float mouse_y)
	{
		int trailing = 0;
		var layout = (element as TextElement).text.layout;
		if (!layout.xy_to_index((int)mouse_x * Pango.SCALE,
		                        (int)mouse_y * Pango.SCALE,
		                        out cursor_index, out trailing))
		{
			debug("Edit click not inside element (%f, %f)", mouse_x, mouse_y);
			return true;
		}
		cursor_index += trailing;
		selection_index = cursor_index;
		position_cursor();
		cursor.opacity = 255;
		cursor_timeline.rewind();
		
		Clutter.grab_pointer(this);
		debug("%p grab", Clutter.get_pointer_grab());
		button_release_event.connect(on_button_release_event);
		motion_event.connect(on_motion_event);
		
		return true;
	}
	
	private bool on_motion_event(Clutter.Actor self, Clutter.MotionEvent event)
	{
		float mouse_x, mouse_y;
		transform_stage_point(event.x, event.y, out mouse_x, out mouse_y);
		
		int trailing, index;
		var layout = (element as TextElement).text.layout;
		if (!layout.xy_to_index((int)mouse_x * Pango.SCALE,
		                        (int)mouse_y * Pango.SCALE,
		                        out index, out trailing))
		{
			return false;
		}
		
		selection_index = index + trailing;
		render_text();
		
		debug("Selection index: %i    Cursor index: %i",
		      selection_index, cursor_index);
		
		return true;
	}
	
	private bool on_button_release_event(Clutter.Actor self,
	                                     Clutter.ButtonEvent event)
	{
		debug("Pointer released");
		button_release_event.disconnect(on_button_release_event);
		motion_event.disconnect(on_motion_event);
		Clutter.ungrab_pointer();
		return true;
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
		// create render context
		texture.clear();
		texture.set_surface_size((uint)texture.width, (uint)texture.height);
		var cr = texture.create();
		cr.save();
		
		// render the selection if applicable
		if (selection_index != cursor_index)
		{
			// get the layout and set its size
			var layout = (element as TextElement).text.layout;
			layout.set_width((int)texture.width);
			layout.set_height((int)texture.height);
			
			// get the lines of the layout
			/*unowned SList<Pango.LayoutLine> lines = layout.get_lines_readonly();
			Pango.LayoutLine start = null, end = null;
			var start_char = 0, end_char = 0, i = 0;
			
			// find the start line and index
			for (; lines != null; lines = lines.next)
			{
				if (lines.data.start_index + lines.data.length > selection_index
				    && selection_index < cursor_index)
				{
					start = lines.data;
					start_char = selection_index - lines.data.start_index;
					break;
				}
				if (lines.data.start_index > cursor_index
				    && cursor_index < selection_index)
				{
					start = lines.data;
					start_char = cursor_index = lines.data.start_index;
					break;
				}
				i++;
			}
			
			// find the end line and index
			/*for (; lines != null; lines = lines.next)
			{
				if (lines.data.start_index + lines.data.length > selection_index
				    && selection_index > cursor_index)
				{
					end = lines.data;
					end_char = selection_index - lines.data.start_index;
					break;
				}
				if (lines.data.start_index > cursor_index
				    && cursor_index > selection_index)
				{
					end = lines.data;
					end_char = cursor_index - lines.data.start_index;
					break;
				}
				i++;
			}
			
			if (start == null)
			{
				critical("Start line not found");
				return;
			}
			if (end == null)
			{
				critical("End line not found");
				return;
			}
			
			//debug("start: %i %i end: %i %i", start, start_char, end, end_char);
			
			// render the selection box
			cr.set_source_rgb(0, 0, 0);
			int x;
			Pango.Rectangle ink, logical;
			start.index_to_x(start_char, false, out x);
			start.get_pixel_extents(out ink, out logical);
			cr.move_to(x / Pango.SCALE, logical.y);
			cr.move_to(x / Pango.SCALE, logical.y + logical.height);*/
			
			int start_index, end_index;
			if (selection_index < cursor_index)
			{
				start_index = selection_index;
				end_index = cursor_index;
			}
			else
			{
				end_index = selection_index;
				start_index = cursor_index;
			}
			
			// render the selection box
			cr.set_source_rgb(0, 0, 0);
			Pango.Rectangle start_rect, end_rect;
			layout.index_to_pos(start_index, out start_rect);
			layout.index_to_pos(end_index, out end_rect);
			
			// see if we can just draw a simple rectangle
			if (start_rect.y == end_rect.y)
			{
				cr.rectangle(start_rect.x / SCALE, start_rect.y / SCALE,
				             (end_rect.x - start_rect.x) / SCALE,
				             (start_rect.y + start_rect.height) / SCALE);
				debug("Rendering selection as rect with (%i %i) (%i %i)",
				      start_rect.x / SCALE, start_rect.y / SCALE,
				      (end_rect.x - start_rect.x) / SCALE,
				      (start_rect.y + start_rect.height) / SCALE);
			}
			else
			{
				// top left corner
				cr.move_to(start_rect.x / SCALE,
					       (start_rect.y + start_rect.height) / SCALE);
				cr.line_to(start_rect.x / SCALE, start_rect.y / SCALE);
				cr.line_to((int)texture.width, start_rect.y / SCALE);
				cr.close_path();
			}
			           
			// fill and stroke
			cr.stroke_preserve();
			cr.fill();
		}
		
		// render the text
		cr.restore();
		(element as TextElement).text.render(cr, !editing,
		                                     (int)texture.width,
		                                     (int)texture.height);
	}
}

