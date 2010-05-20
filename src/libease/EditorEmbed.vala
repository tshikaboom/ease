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
 * The main editing widget.
 *
 * EditorEmbed is the outermost part of the editing canvas in an Ease
 * window. Each EditorEmbed is linked to a {@link Document}, and
 * changes in the editor are immediately reflected in the Document, but
 * are not saved to disk until the user clicks on a save button or
 * menu item.
 * 
 * EditorEmbed is a subclass of {@link ScrollableEmbed}, and has both
 * horizontal and vertical scrollbars.
 */
public class Ease.EditorEmbed : ScrollableEmbed
{
	// the editorwindow
	private EditorWindow win;

	// overall display
	private Clutter.Rectangle view_background;
	
	// selection rectangle
	private Clutter.Rectangle selection_rectangle;
	
	// handles
	private Handle[] handles;

	// the current slide's actor
	public SlideActor slide_actor;
	
	// the currently selected Actor
	private Actor selected;
	
	// if the selected Actor is being dragged
	private bool is_dragging;
	private bool is_drag_ready;
	private float mouse_x;
	private float mouse_y;
	
	// the origin position of a dragged element
	private float orig_x;
	private float orig_y;
	private float orig_w;
	private float orig_h;
	
	private Document document;
	public float zoom;
	public bool zoom_fit;

	/**
	 * Create an EditorEmbed representing a {@link Document}.
	 * 
	 * EditorEmbed is the outermost part of the editing canvas in an Ease
	 * window. Each EditorEmbed is linked to a {@link Document}, and
	 * changes in the editor are immediately reflected in the Document, but
	 * are not saved to disk until the user clicks on a save button or
	 * menu item. 
	 *
	 * @param d The {@link Document} this EditorEmbed represents.
	 * @param w The {@link EditorWindow} this EditorEmbed is part of.
	 */
	public EditorEmbed(Document d, EditorWindow w)
	{
		base(true);
		win = w;

		// set up the background
		view_background = new Clutter.Rectangle();
		var color = Clutter.Color();
		color.from_string("Gray");
		view_background.color = color;
		contents.add_actor(view_background);
		
		document = d;
		set_size_request(320, 240);

		zoom = 1;
		zoom_fit = false;

		// reposition everything when resized
		size_allocate.connect(() => {
			if (zoom_fit)
			{
				zoom = width / height > (float)document.width / document.height
				     ? height / document.height
				     : width / document.width;
				reposition_group();
			}
			else
			{
				reposition_group();
			}

			// set the size of the background
			view_background.width = (float)Math.fmax(width, slide_actor.width);
			view_background.height = height;
		});
	}

	/**
	 * Sets the zoom level of the slide displayed by this EditorEmbed.
	 * 
	 * When this function is called, only the EditorEmbed's zoom level is
	 * set. Therefore, any other relevant parts of the interface should
	 * also be updated by the caller. 
	 *
	 * @param z The zoom level, on a 0-100 scale (higher values, are, of
	 * course, possible, but values below 10 or so are unlikely to produce
	 * desirable results.
	 */
	public void set_zoom(float z)
	{
		zoom = z / 100;
		reposition_group();
	}

	/**
	 * Sets the current {@link Slide} that the EditorEmbed is displaying.
	 * 
	 * The current slide is displayed in the center of the EditorEmbed.
	 * Components of it should also be editable via interface elements such
	 * as the Inspector.
	 *
	 * This function will work with a {@link Slide} that is not in the
	 * displayed {@link Document}. For obvious reasons, this is not a 
	 * particularly good idea.
	 *
	 * @param node The initial XML node to begin with.
	 */
	public void set_slide(Slide slide)
	{
		if (slide == null)
		{
			return;
		}
		
		// clean up the previous slide
		if (slide_actor != null)
		{
			contents.remove_actor(slide_actor);
			for (unowned List<Clutter.Actor>* itr = slide_actor.contents.get_children();
			     itr != null;
			     itr = itr->next)
			{
				((Actor*)(itr->data))->button_press_event.disconnect(actor_clicked);
				((Actor*)(itr->data))->button_release_event.disconnect(actor_released);
				((Actor*)(itr->data))->set_reactive(false);
			}
		}
		
		// remove the selection rectangle
		if (selection_rectangle != null)
		{
			if (selection_rectangle.get_parent() == contents)
			{
				contents.remove_actor(selection_rectangle);
			}
			foreach (var h in handles)
			{
				if (h.get_parent() == contents)
				{
					contents.remove_actor(h);
				}
				h.button_press_event.disconnect(handle_clicked);
				h.button_release_event.disconnect(handle_released);
			}
		}
		
		// create a new SlideActor
		slide_actor = new SlideActor.from_slide(document,
		                                        slide,
		                                        false,
		                                        ActorContext.EDITOR);
		                                        
		// make the elements clickable
		for (unowned List<Clutter.Actor>* itr = slide_actor.contents.get_children();
		     itr != null;
		     itr = itr->next)
		{
			
			((Actor*)(itr->data))->button_press_event.connect(actor_clicked);
			((Actor*)(itr->data))->button_release_event.connect(actor_released);
			((Actor*)(itr->data))->set_reactive(true);
		}
		
		contents.add_actor(slide_actor);
		reposition_group();
	}

	/**
	 * Repositions the EditorEmbed's {@link SlideActor}.
	 * 
	 * Call this function after changing the zoom level, document size, or
	 * any other properties that could place the slide off center. 
	 */
	public void reposition_group()
	{
		if (slide_actor == null)
		{
			return;
		}
		
		var w = zoom * document.width;
		var h = zoom * document.height;
		
		slide_actor.set_scale_full(zoom, zoom, 0, 0);

		slide_actor.x = w < width
		              ? width / 2 - w / 2
	                  : 0;
		        
		slide_actor.y = h < height
		              ? height / 2 - h / 2
		              : 0;
		              
		if (selection_rectangle != null)
		{
			position_selection();
		}
	}
	
	/**
	 * Repositions the EditorEmbed's selection rectangle
	 * 
	 * Call this function after changing the zoom level, document size, or
	 * any other properties that could place the slide off center. 
	 */
	private void position_selection()
	{
		selection_rectangle.set_position(zoom * selected.x + slide_actor.x,
			                             zoom * selected.y + slide_actor.y);
		selection_rectangle.set_size(zoom * selected.width,
		                             zoom * selected.height);
		
		foreach (var h in handles)
		{
			h.reposition(selection_rectangle);
		}
	}
	
	/**
	 * Signal handler for clicking on {@link Actor}s.
	 * 
	 * This handler is attached to the button_press_event of all
	 * {@link Actor}s in the currently displayed {@link SlideActor}.
	 *
	 * @param sender The {@link Actor} that was clicked
	 * @param event The corresponding Clutter.Event
	 */
	public bool actor_clicked(Clutter.Actor sender, Clutter.Event event)
	{
		Actor act = (Actor)sender;
		stdout.printf("Name: %s\n", act.element.data.get("ease_name"));
	
		// if the sender is already selected, drag it
		if (sender == selected)
		{
			is_dragging = true;
			is_drag_ready = false;
			Clutter.grab_pointer(sender);
			sender.motion_event.connect(actor_motion);
			return true;
		}
		
		// remove the selection rectangle and handles
		if (selection_rectangle != null)
		{
			foreach (var h in handles)
			{
				h.button_press_event.disconnect(handle_clicked);
				h.button_release_event.disconnect(handle_released);
				
				if (h.get_parent() == contents)
				{	
					contents.remove_actor(h);
				}
			}
			if (selection_rectangle.get_parent() == contents)
			{
				contents.remove_actor(selection_rectangle);
			}
		}
		
		selected = (Actor)sender;
		
		// make a new selection rectangle
		selection_rectangle = new Clutter.Rectangle();
		selection_rectangle.border_color = {0, 0, 0, 255};
		selection_rectangle.color = {0, 0, 0, 0};
		selection_rectangle.set_border_width(2);
		position_selection();
		contents.add_actor(selection_rectangle);
		
		handles = new Handle[8];
		for (int i = 0; i < 8; i++)
		{
			handles[i] = new Handle((HandlePosition)i);
			handles[i].reposition(selection_rectangle);
			contents.add_actor(handles[i]);
			
			handles[i].button_press_event.connect(handle_clicked);
			handles[i].button_release_event.connect(handle_released);
		}
		
		return true;
	}
	
	/**
	 * Signal handler for releasing an {@link Actor}.
	 * 
	 * This handler is attached to the button_release_event of all
	 * {@link Actor}s in the currently displayed {@link SlideActor}.
	 *
	 * When the {@link Actor} is being dragged, this ends the drag action.
	 *
	 * @param sender The {@link Actor} that was released
	 * @param event The corresponding Clutter.Event
	 */
	public bool actor_released(Clutter.Actor sender, Clutter.Event event)
	{
		if (sender == selected && is_dragging)
		{
			is_dragging = false;
			Clutter.ungrab_pointer();
			sender.motion_event.disconnect(actor_motion);
			win.add_undo_action(new MoveUndoAction(selected.element,
			                                       orig_x, orig_y,
			                                       orig_w, orig_h));
		}
		return true;
	}
	
	/**
	 * Signal handler for dragging an {@link Actor}.
	 * 
	 * This handler is attached to the motion_event of all
	 * {@link Actor}s in the currently displayed {@link SlideActor}.
	 * It will only have an effect if a drag is active.
	 *
	 * @param sender The {@link Actor} that was dragged
	 * @param event The corresponding Clutter.Event
	 */
	public bool actor_motion(Clutter.Actor sender, Clutter.Event event)
	{
		Actor actor = (Actor)sender;
		
		if (sender == selected && is_dragging)
		{
			if (!is_drag_ready)
			{
				is_drag_ready = true;
				mouse_x = event.motion.x;
				mouse_y = event.motion.y;
				
				orig_x = selected.x;
				orig_y = selected.y;
				orig_w = selected.width;
				orig_h = selected.height;
				
				return true;
			}
			
			float factor = 1 / zoom;
			
			actor.translate(factor * (event.motion.x - mouse_x),
			                factor * (event.motion.y - mouse_y));
			
			mouse_x = event.motion.x;
			mouse_y = event.motion.y;
			
			position_selection();
		}
		return true;
	}
	
	/**
	 * Signal handler for clicking on a {@link Handle}.
	 * 
	 * This handler is attached to the button_press_event of all
	 * {@link Handle}s.
	 *
	 * @param sender The {@link Handle} that was clicked
	 * @param event The corresponding Clutter.Event
	 */
	public bool handle_clicked(Clutter.Actor sender, Clutter.Event event)
	{
		is_dragging = true;
		is_drag_ready = false;
		sender.motion_event.connect(handle_motion);
		Clutter.grab_pointer(sender);
		return true;
	}
	
	/**
	 * Signal handler for releasing an {@link Handle}.
	 * 
	 * This handler is attached to the button_release_event of all
	 * {@link Handle}s.
	 *
	 * When the {@link Handle} is being dragged, this ends the drag action.
	 *
	 * @param sender The {@link Handle} that was released
	 * @param event The corresponding Clutter.Event
	 */
	public bool handle_released(Clutter.Actor sender, Clutter.Event event)
	{
		if (is_dragging)
		{
			is_dragging = false;
			sender.motion_event.disconnect(handle_motion);
			
			win.add_undo_action(new MoveUndoAction(selected.element,
			                                       orig_x, orig_y,
			                                       orig_w, orig_h));
		}
		
		Clutter.ungrab_pointer();
		return true;
	}
	
	/**
	 * Signal handler for dragging an {@link Handle}.
	 * 
	 * This handler is attached to the motion_event of all
	 * {@link Handle}s.
	 *
	 * It will only have an effect if a drag is active.
	 *
	 * @param sender The {@link Handle} that was dragged
	 * @param event The corresponding Clutter.Event
	 */
	public bool handle_motion(Clutter.Actor sender, Clutter.Event event)
	{
		Handle handle = (Handle)sender;
		
		if (!is_drag_ready)
		{
			is_drag_ready = true;
			mouse_x = event.motion.x;
			mouse_y = event.motion.y;
			
			orig_x = selected.x;
			orig_y = selected.y;
			orig_w = selected.width;
			orig_h = selected.height;
			
			return true;
		}
		
		float factor = 1 / zoom;
		var motion = event.motion;
		var p = (motion.modifier_state & Clutter.ModifierType.SHIFT_MASK) != 0;
		float change_x = motion.x - mouse_x;
		float change_y = motion.y - mouse_y;
		
		// if control is held, resize from the center
		if ((motion.modifier_state & Clutter.ModifierType.CONTROL_MASK) != 0)
		{
			handle.drag_from_center(factor * change_x, factor * change_y,
			                        selected, p);
		}
		
		// otherwise, drag normally
		else
		{
			handle.drag(factor * change_x, factor * change_y, selected, p);
		}
		
		mouse_x = motion.x;
		mouse_y = motion.y;
		
		position_selection();
		
		return true;
	}
}

