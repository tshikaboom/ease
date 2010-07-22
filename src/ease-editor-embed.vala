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
	/**
	 * The {@link EditorWindow} that owns this EditorEmbed.
	 */
	private EditorWindow win;
	
	/**
	 * The rectangle displayed around selected {@link Actor}s.
	 */
	private Clutter.Rectangle selection_rectangle;
	
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
	 * The split string for parsing GTK colors.
	 */
	private const string SPLIT = "\n;";
	
	/**
	 * The gtk background color identifier.
	 */
	private const string BG_COLOR = "bg_color:";
	
	/**
	 * The gtk background color prefix.
	 */
	private const string PREFIX = "#";
	
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
	 * The {@link Document} linked with this EditorEmbed.
	 */
	private Document document;
	
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
		
		// find the appropriate color
		var settings = Gtk.Settings.get_default();
		var colors = settings.gtk_color_scheme.split_set(SPLIT);
		for (int i = 0; i < colors.length; i++)
		{
			colors[i] = colors[i].strip();
			
			if (colors[i].has_prefix(BG_COLOR))
			{
				for (; !colors[i].has_prefix(PREFIX) && colors[i].length > 3;
			         colors[i] = colors[i].substring(1, colors[i].length - 1));
				
				Gdk.Color gdk_color;
				Gdk.Color.parse(colors[i], out gdk_color);
				
				Clutter.Color clutter_color = { (uchar)(gdk_color.red / 256),
				                                (uchar)(gdk_color.green / 256),
				                                (uchar)(gdk_color.blue / 256),
				                                255};
				
				Clutter.Color out_color;
				
				clutter_color.shade(SHADE_FACTOR, out out_color);
				
				get_stage().color = out_color;
				
				break;
			}
		}
		
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
			for (unowned List<Clutter.Actor>* itr =
			     slide_actor.contents.get_children();
			     itr != null;
			     itr = itr->next)
			{
				((Actor*)(itr->data))->button_press_event.disconnect(actor_clicked);
				((Actor*)(itr->data))->button_release_event.disconnect(actor_released);
				((Actor*)(itr->data))->reactive = false;
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
			handles = null;
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
			((Actor*)(itr->data))->reactive = true;
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

		slide_actor.x = roundd(w < width
		                            ? width / 2 - w / 2
	                                : 0);
		        
		slide_actor.y = roundd(h < height
		                            ? height / 2 - h / 2
		                            : 0);
		              
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
	 * Recreates the current SlideActor.
	 */
	public void recreate_slide()
	{
		set_slide(slide_actor.slide);
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
			return true;
		}
		
		// if editing another Actor, finish that edit
		if (selected != null && is_editing)
		{
			selected.end_edit(this);
			is_editing = false;
		}
		
		// remove the selection rectangle and handles
		if (selection_rectangle != null)
		{
			if (selection_rectangle.get_parent() == contents)
			{
				contents.remove_actor(selection_rectangle);
			}
		}
		
		selected = sender as Actor;
		
		// make a new selection rectangle
		selection_rectangle = new Clutter.Rectangle();
		selection_rectangle.border_color = {0, 0, 0, 255};
		selection_rectangle.color = {0, 0, 0, 0};
		selection_rectangle.border_width = 2;
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
	private bool actor_released(Clutter.Actor sender, Clutter.ButtonEvent event)
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
}

