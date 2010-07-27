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
public class Ease.EditorEmbed : ScrollableEmbed, UndoSource
{
	/**
	 * The {@link EditorWindow} that owns this EditorEmbed.
	 */
	private EditorWindow win;
	
	/**
	 * The rectangle displayed around selected {@link Actor}s.
	 */
	private SelectionRectangle selection_rectangle;
	
	/**
	 * The {@link Handle}s attached to the selection rectangle.
	 */
	private Handle[] handles;

	/**
	 * The current slide's actor.
	 */
	public SlideActor slide_actor;
	
	/**
	 * The currently selected {@link Actor}.
	 */
	public Actor selected { get; private set; }
	
	/**
	 * If the selected {@link Actor} is being edited.
	 */
	private bool is_editing { get; set; }
	
	/**
	 * If the selected Actor is being dragged.
	 */
	private bool is_dragging;
	
	/**
	 * If the drag has been initialized.
	 */
	private bool is_drag_initialized;
	
	/**
	 * An UndoAction to be added on drag/resize completion.
	 */
	private UndoAction move_undo;
	
	/**
	 * The X position of the mouse in the prior drag event.
	 */
	private float mouse_x;
	
	/**
	 * The Y position of the mouse in the prior drag event.
	 */
	private float mouse_y;
	
	/**
	 * The original X position of a dragged {@link Actor}.
	 */
	private float orig_x;
	
	/**
	 * The original Y position of a dragged {@link Actor}.
	 */
	private float orig_y;
	
	/**
	 * The original width of a dragged {@link Actor}.
	 */
	private float orig_w;
	
	/**
	 * The original height of a dragged {@link Actor}.
	 */
	private float orig_h;
	
	/**
	 * If the embed is currently receiving key events.
	 */
	private bool keys_connected = false;
	
	/**
	 * The gtk background color identifier.
	 */
	private const string BG_COLOR = "bg_color:";
	
	/**
	 * The shade factor of the EditorEmbed's background relative to typical
	 * GTK background color.
	 */
	private const double SHADE_FACTOR = 0.9;
	
	/**
	 * The size of the handles[] array.
	 */
	private const int HANDLE_COUNT = 8;
	
	/**
	 * The number of pixels an actor moves when nudged.
	 */
	private const int NUDGE_PIXELS = 10;
	
	/**
	 * The number of pixels an actor moves when nudged with shift held down.
	 */
	private const int NUDGE_SHIFT_PIXELS = 50;
	
	/**
	 * The {@link Document} linked with this EditorEmbed.
	 */
	private Document document;
	
	public signal void element_selected(Element selected);
	public signal void element_deselected(Element? deselected);
	
	/**
	 * The zoom level of the slide displayed by this EditorEmbed.
	 * 
	 * When this property is set is called, only the EditorEmbed's zoom level
	 * is set. Therefore, any other relevant parts of the interface should
	 * also be updated by the method setting the zoom value.
	 *
	 * The zoom level is set on a 0-1 scale. Higher values, are, of
	 * course, possible, but values below 0.1 or so are unlikely to produce
	 * desirable results.
	 */
	public float zoom
	{
		get
		{
			return zoom_priv;
		}
		set
		{
			zoom_priv = value;
			reposition_group();
		}
	}
	
	/**
	 * Store for "zoom" property.
	 */
	private float zoom_priv;
	
	/**
	 * If the zoom factor should automatically be set to fill the EditorEmbed.
	 */
	private bool zoom_fit { get; set; }

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
		base(true, true);
		win = w;
		
		// don't fade actors out when zoomed out
		get_stage().use_fog = false;
		
		// set the background to a faded version of the normal gtk background
		Clutter.Color out_color;
		var color = theme_color(BG_COLOR);
		if (color == null)
		{
			out_color = { 150, 150, 150, 255 };
			out_color.shade(SHADE_FACTOR, out out_color);
		}
		else
		{
			out_color = Transformations.gdk_color_to_clutter_color(color);
		}
		
		get_stage().color = out_color;
		
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
		});
		
		connect_keys();
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
		if (slide == null) return;
		
		if (is_editing)
		{
			selected.end_edit(this);
			is_editing = false;
		}
		
		connect_keys();
		deselect_actor();
		element_deselected(null);
		
		// clean up the previous slide
		if (slide_actor != null)
		{
			contents.remove_actor(slide_actor);
			foreach (var a in slide_actor.contents)
			{
				a.button_press_event.disconnect(actor_clicked);
				a.button_release_event.disconnect(actor_released);
				a.reactive = false;
			}
			
			slide_actor.ease_actor_added.disconnect(on_ease_actor_added);
			slide_actor.ease_actor_removed.disconnect(on_ease_actor_removed);
			slide_actor.slide.element_removed.disconnect(on_element_removed);
		}
		
		// remove the selection rectangle
		remove_selection_rect();
		
		// create a new SlideActor
		slide_actor = new SlideActor.from_slide(document,
		                                        slide,
		                                        false,
		                                        ActorContext.EDITOR);
		                                        
		// make the elements clickable
		foreach (var a in slide_actor.contents)
		{
			a.button_press_event.connect(actor_clicked);
			a.button_release_event.connect(actor_released);
			a.reactive = true;
		}
		
		slide_actor.ease_actor_added.connect(on_ease_actor_added);
		slide_actor.ease_actor_removed.connect(on_ease_actor_removed);
		slide_actor.slide.element_removed.connect(on_element_removed);
		
		contents.add_actor(slide_actor);
		reposition_group();
	}
	
	/**
	 * Removes the selection rectangle and handles.
	 */
	private void remove_selection_rect()
	{
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
			handles = null;
		}
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
		
		var w = zoom * slide_actor.slide.width;
		var h = zoom * slide_actor.slide.height;
		
		slide_actor.set_scale_full(zoom, zoom, 0, 0);

		slide_actor.x = roundd(w < width
		                       ? width / 2 - w / 2
	                           : 0);
		        
		slide_actor.y = roundd(h < height
		                       ? height / 2 - h / 2
		                       : 0);
		              
		if (selection_rectangle != null && selected != null)
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
	 * Recreates the current SlideActor.
	 */
	public void recreate_slide()
	{
		set_slide(slide_actor.slide);
	}
	
	/**
	 * Selects an {@link Actor} by {@link Element}.
	 *
	 * @param e The element to search for.
	 */
	public void select_element(Element e)
	{
		foreach (var a in slide_actor.contents)
		{
			if ((a as Actor).element == e)
			{
				select_actor(a as Actor);
			}
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
	private bool actor_clicked(Clutter.Actor sender, Clutter.ButtonEvent event)
	{
		// if this is a double click, edit the actor
		if (event.click_count == 2)
		{
			disconnect_keys();
			(sender as Actor).edit(this);
			is_editing = true;
			return true;
		}
		
		// otherwise, if the sender is already selected, drag it
		else if (sender == selected)
		{
			is_dragging = true;
			is_drag_initialized = false;
			Clutter.grab_pointer(sender);
			sender.motion_event.connect(actor_motion);
			
			// create an UndoAction for this drag
			move_undo = new UndoAction(selected.element, "x");
			move_undo.add(selected.element, "y");
			
			return true;
		}
		
		select_actor(sender as Actor);
		
		return true;
	}
	
	/**
	 * Selects an {@link Actor}.
	 *
	 * @param sender The Actor to select.
	 */
	private void select_actor(Actor sender)
	{
		// deselect anything that is currently selected
		deselect_actor();
		
		connect_keys();
		
		selected = sender as Actor;
		element_selected(selected.element);
		
		// make a new selection rectangle
		selection_rectangle = new SelectionRectangle();
		position_selection();
		contents.add_actor(selection_rectangle);
		
		// place the handles
		if (handles == null)
		{
			handles = new Handle[HANDLE_COUNT];
			for (int i = 0; i < HANDLE_COUNT; i++)
			{
				handles[i] = new Handle((HandlePosition)i);
				contents.add_actor(handles[i]);
				handles[i].button_press_event.connect(handle_clicked);
				handles[i].button_release_event.connect(handle_released);
			}
		}
		
		for (int i = 0; i < HANDLE_COUNT; i++)
		{
			handles[i].reposition(selection_rectangle);
			contents.raise_child(handles[i], selection_rectangle);
		}
		
		// when something is selected, the embed grabs key focus
		set_can_focus(true);
		grab_focus();
	}
	
	/**
	 * Deselects the currently selected {@link Actor}.
	 *
	 * This method is safe to call if nothing is selected.
	 */
	private void deselect_actor()
	{
		// if editing another Actor, finish that edit
		if (selected != null && is_editing)
		{
			selected.end_edit(this);
			is_editing = false;
			element_deselected(selected.element);
		}
		connect_keys();
		
		// deselect
		selected = null;
		
		// remove the selection rectangle and handles
		remove_selection_rect();
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
	private bool actor_released(Clutter.Actor sender, Clutter.ButtonEvent event)
	{
		if (sender == selected && is_dragging)
		{
			is_dragging = false;
			Clutter.ungrab_pointer();
			sender.motion_event.disconnect(actor_motion);
			undo(move_undo);
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
	private bool actor_motion(Clutter.Actor sender, Clutter.MotionEvent event)
	{
		Actor actor = (Actor)sender;
		
		if (sender == selected && is_dragging)
		{
			if (!is_drag_initialized)
			{
				is_drag_initialized = true;
				mouse_x = event.x;
				mouse_y = event.y;
				
				orig_x = selected.x;
				orig_y = selected.y;
				orig_w = selected.width;
				orig_h = selected.height;
				
				return true;
			}
			
			float factor = 1 / zoom;
			
			actor.translate(factor * (event.x - mouse_x),
			                factor * (event.y - mouse_y));
			
			mouse_x = event.x;
			mouse_y = event.y;
			
			position_selection();
			
			selected.element.parent.changed(selected.element.parent);
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
	private bool handle_clicked(Clutter.Actor sender, Clutter.ButtonEvent event)
	{
		(sender as Handle).flip(true);
		is_dragging = true;
		is_drag_initialized = false;
		sender.motion_event.connect(handle_motion);
		Clutter.grab_pointer(sender);
		
		// create an UndoAction for this resize
		move_undo = new UndoAction(selected.element, "x");
		move_undo.add(selected.element, "y");
		move_undo.add(selected.element, "width");
		move_undo.add(selected.element, "height");
		
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
	private bool handle_released(Clutter.Actor sender, Clutter.ButtonEvent event)
	{
		if (is_dragging)
		{
			(sender as Handle).flip(false);
			is_dragging = false;
			sender.motion_event.disconnect(handle_motion);
			undo(move_undo);
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
	private bool handle_motion(Clutter.Actor sender, Clutter.MotionEvent event)
	{
		Handle handle = (Handle)sender;
		
		if (!is_drag_initialized)
		{
			is_drag_initialized = true;
			mouse_x = event.x;
			mouse_y = event.y;
			
			orig_x = selected.x;
			orig_y = selected.y;
			orig_w = selected.width;
			orig_h = selected.height;
			
			return true;
		}
		
		float factor = 1 / zoom;
		var p = (event.modifier_state & Clutter.ModifierType.SHIFT_MASK) != 0;
		float change_x = event.x - mouse_x;
		float change_y = event.y - mouse_y;
		
		// if control is held, resize from the center
		if ((event.modifier_state & Clutter.ModifierType.CONTROL_MASK) != 0)
		{
			handle.drag_from_center(factor * change_x, factor * change_y,
			                        selected, p);
		}
		
		// otherwise, drag normally
		else
		{
			handle.drag(factor * change_x, factor * change_y, selected, p);
		}
		
		mouse_x = event.x;
		mouse_y = event.y;
		
		position_selection();
		
		selected.element.parent.changed(selected.element.parent);
		
		return true;
	}
	
	/**
	 * Sets the color of the currently selected element, if applicable.
	 *
	 * If no element is selected, or the selected element does not have a
	 * "color" property, this property is ignored.
	 */
	public void set_element_color(Clutter.Color color)
	{
		if (selected == null) return;	
		if (!selected.element.set_color(color)) return;
	}
	
	/**
	 * Handles actor removal events. Deselects the current
	 * {@link Actor} if necessary, and disconnects handlers.
	 */
	public void on_ease_actor_removed(Actor actor)
	{
		if (selected == actor) deselect_actor();
		actor.button_press_event.disconnect(actor_clicked);
		actor.button_release_event.disconnect(actor_released);
		actor.reactive = false;
	}
	
	/**
	 * Handles new actor events. Connects handlers.
	 */
	public void on_ease_actor_added(Actor actor)
	{
		actor.button_press_event.connect(actor_clicked);
		actor.button_release_event.connect(actor_released);
		actor.reactive = true;
	}
	
	/**
	 * Handles keypresses within the embed.
	 */
	public bool on_key_press_event(Gtk.Widget self, Gdk.EventKey event)
	{
		if (event.type == Gdk.EventType.KEY_RELEASE) return false;
		
		bool shift = (event.state & Gdk.ModifierType.SHIFT_MASK) != 0;
		
		switch (event.keyval)
		{
			case Key.UP:
				if (selected == null) break;
				if (is_editing) return true;
				
				undo(new UndoAction(selected.element, "y"));
				selected.translate(0, shift ?
				                      -NUDGE_SHIFT_PIXELS : -NUDGE_PIXELS);
				position_selection();			
				selected.element.parent.changed(selected.element.parent);
				return true;
			
			case Key.DOWN:
				if (selected == null) break;
				if (is_editing) return true;
				
				undo(new UndoAction(selected.element, "y"));
				selected.translate(0, shift ?
				                      NUDGE_SHIFT_PIXELS : NUDGE_PIXELS);
				position_selection();			
				selected.element.parent.changed(selected.element.parent);
				return true;
				
			case Key.LEFT:
				if (selected == null) break;
				if (is_editing) return true;
				
				undo(new UndoAction(selected.element, "x"));
				selected.translate(shift ?
				                   -NUDGE_SHIFT_PIXELS : -NUDGE_PIXELS, 0);
				position_selection();			
				selected.element.parent.changed(selected.element.parent);
				return true;
			
			case Key.RIGHT:
				if (selected == null) break;
				if (is_editing) return true;
				
				undo(new UndoAction(selected.element, "x"));
				selected.translate(shift ?
				                   NUDGE_SHIFT_PIXELS : NUDGE_PIXELS, 0);
				position_selection();			
				selected.element.parent.changed(selected.element.parent);
				return true;
			
			case Key.BACKSPACE:
			case Key.DELETE:
				if (selected == null) break;
				
				var slide = slide_actor.slide;
				var i = slide.index_of(selected.element);
				undo(new ElementRemoveUndoAction(slide.element_at(i)));
				slide.remove_at(i);
				element_deselected(null);
				
				return true;
		}
		
		return false;
	}
	
	/**
	 * Handles {@link Slide.element_removed}.
	 */
	public void on_element_removed(Slide slide, Element element, int index)
	{
		if (slide != slide_actor.slide) return;
		if (selected == null) element_deselected(element);
	}
	
	/**
	 * Connects the key event handlers.
	 */
	public void connect_keys()
	{
		if (keys_connected) return;
		keys_connected = true;
		key_press_event.connect(on_key_press_event);
	}
	
	/**
	 * Disconnects the key event handlers.
	 */
	public void disconnect_keys()
	{
		if (!keys_connected) return;
		keys_connected = false;
		key_press_event.disconnect(on_key_press_event);
	}
}

