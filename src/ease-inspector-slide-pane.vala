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
 * The inspector pane concerning slides
 */
public class Ease.InspectorSlidePane : InspectorPane
{
	private const string UI_FILE_PATH = "inspector-slide.ui";
	private const string BG_DIALOG_TITLE = _("Select Background Image");
	
	private Gtk.ComboBox background;
	private Gtk.ListStore store;
	private Gtk.ComboBox gradient_type;
	private Gtk.ListStore grad_store = GradientType.list_store();
	private Gtk.VBox box_color;
	private Gtk.VBox box_gradient;
	private Gtk.VBox box_image;
	
	private Gtk.ColorButton bg_color;
	private Gtk.ColorButton grad_color1;
	private Gtk.ColorButton grad_color2;
	private Gtk.FileChooserButton bg_image;
	
	private bool silence_undo;

	public InspectorSlidePane()
	{	
		base();
		
		// load the GtkBuilder file
		var builder = new Gtk.Builder();
		try
		{
			builder.add_from_file(data_path(Path.build_filename(Temp.UI_DIR,
				                                                UI_FILE_PATH)));
		}
		catch (Error e) { error("Error loading UI: %s", e.message); }
		
		// connect signals
		builder.connect_signals(this);
		
		// add the root of the builder file to this widget
		pack_start(builder.get_object("root") as Gtk.Widget, true, true, 0);
		
		// get controls
		box_color = builder.get_object("vbox-color") as Gtk.VBox;
		box_gradient = builder.get_object("vbox-gradient") as Gtk.VBox;
		box_image = builder.get_object("vbox-image") as Gtk.VBox;
		bg_color = builder.get_object("color-color") as Gtk.ColorButton;
		grad_color1 =
			builder.get_object("color-startgradient") as Gtk.ColorButton;
		grad_color2 =
			builder.get_object("color-endgradient") as Gtk.ColorButton;
		bg_image =
			builder.get_object("button-image") as Gtk.FileChooserButton;
		gradient_type =
			builder.get_object("combo-gradient") as Gtk.ComboBox;
		
		// set up the gradient type combobox
		gradient_type.model = grad_store;
		
		// get the combobox
		background = builder.get_object("combobox-style") as Gtk.ComboBox;
		
		// build a liststore for the combobox
		store = new Gtk.ListStore(2, typeof(string), typeof(BackgroundType));
		Gtk.TreeIter iter;
		foreach (var b in BackgroundType.TYPES)
		{
			store.append(out iter);
			store.set(iter, 0, b.description(), 1, b);
		}
		
		var render = new Gtk.CellRendererText();
		
		background.pack_start(render, true);
		background.set_attributes(render, "text", 0);
		
		background.model = store;
	}
	
	private void emit_undo(UndoAction action)
	{
		if (!silence_undo) undo(action);
	}
	
	[CCode (instance_pos = -1)]
	public void on_background_changed(Gtk.Widget? sender)
	{
		Gtk.TreeIter itr;
		store.get_iter_first(out itr);
		
		// find the correct position
		for (int i = 0; i < background.active; i++) store.iter_next(ref itr);
		
		// get the background type at that position
		BackgroundType type;
		store.get(itr, 1, out type);
		
		// create an undo action
		var action = new UndoAction(slide, "background-type");
		
		// ease can't provide a default for images, so one must be requested
		if (type == BackgroundType.IMAGE && slide.background_image == null)
		{
			var dialog = new Gtk.FileChooserDialog(BG_DIALOG_TITLE,
			                                       widget_window(this),
			                                       Gtk.FileChooserAction.OPEN,
			                                       "gtk-cancel",
			                                       Gtk.ResponseType.CANCEL,
			                                       "gtk-open",
			                                       Gtk.ResponseType.ACCEPT);
			switch (dialog.run())
			{
				case Gtk.ResponseType.ACCEPT:
					try
					{
						var fname = dialog.get_filename();
						slide.background_image_source = fname;
						var i = slide.parent.add_media_file(fname);
						slide.background_image = i;
					}
					catch (GLib.Error e)
					{
						critical("Error adding background image: %s",
						         e.message);
					}
					dialog.destroy();
					break;
				case Gtk.ResponseType.CANCEL:
					action.apply();
					dialog.destroy();
					return;
			}
		}
		
		// when the action is applied, if the slide is still current, change ui
		var local = slide;
		action.applied.connect((a) => {
			if (local == slide)
			{
				silence_undo = true;
				background.set_active(slide.background_type);
				display_bg_ui(slide.background_type);
				silence_undo = false;
			}
		});
		
		// add properties to the UndoAction and report it to the controller
		switch (type)
		{
			case BackgroundType.COLOR:
				action.add(slide, "background-color");
				break;
			case BackgroundType.GRADIENT:
				action.add(slide, "background-gradient");
				break;
			case BackgroundType.IMAGE:
				action.add(slide, "background-image");
				break;
		}
		emit_undo(action);
		
		// switch to that background type
		display_bg_ui(type);
	}
	
	[CCode (instance_pos = -1)]
	public void on_gradient_type_changed(Gtk.ComboBox? sender)
	{
		emit_undo(new UndoAction(slide.background_gradient, "mode"));
		slide.background_gradient.mode = (GradientType)sender.get_active();
		slide.changed(slide);
	}
	
	[CCode (instance_pos = -1)]
	public void on_color_set(Gtk.ColorButton? sender)
	{
		if (sender == bg_color)
		{
			emit_undo(slide.background_color.undo_action());
			slide.background_color.gdk = sender.color;
		}
		else if (sender == grad_color1)
		{
			emit_undo(slide.background_gradient.start.undo_action());
			slide.background_gradient.start.gdk = sender.color;
		}
		else if (sender == grad_color2)
		{
			emit_undo(slide.background_gradient.end.undo_action());
			slide.background_gradient.end.gdk = sender.color;
		}
		slide.changed(slide);
	}
	
	[CCode (instance_pos = -1)]
	public void on_file_set(Gtk.FileChooserButton? sender)
	{
		var action = new UndoAction(slide, "background-image");
		action.add(slide, "background-image-source");
		
		// slide might change in the meantime
		var local = slide;
		
		// set the button's filename when the action is applied
		action.applied.connect((a) => {
			// if slide changes, this is still ok
			if (slide.background_image_source != null)
			{
				bg_image.set_filename(slide.background_image_source);
			}
			else
			{
				bg_image.unselect_all();
			}
			local.changed(local);
			display_bg_ui(slide.background_type);
		});
		
		try
		{
			slide.background_image_source = sender.get_filename();
			var i = slide.parent.add_media_file(sender.get_filename());
			slide.background_image = i;
		}
		catch (GLib.Error e)
		{
			critical("Error adding background image: %s", e.message);
		}
		
		slide.changed(slide);
		
		emit_undo(action);
	}
	
	[CCode (instance_pos = -1)]
	public void on_reverse_gradient(Gtk.Widget? sender)
	{
		// create an undo action
		var action = new UndoAction(slide.background_gradient, "start");
		action.add(slide.background_gradient, "end");
		
		// flip the gradient
		slide.background_gradient.flip();
		
		// update the ui
		grad_color1.set_color(slide.background_gradient.start.gdk);
		grad_color2.set_color(slide.background_gradient.end.gdk);
		slide.changed(slide);
		
		// add the undo action
		emit_undo(action);
	}
	
	protected override void slide_updated()
	{
		silence_undo = true;
		
		// set the combo box to the slide's active background type
		background.set_active(slide.background_type);
		
		// set the gradient box to the correct mode
		if (slide.background_gradient != null)
		{
			gradient_type.set_active(slide.background_gradient.mode);
		}
		
		display_bg_ui(slide.background_type);
		
		silence_undo = false;
	}
	
	private void display_bg_ui(BackgroundType type)
	{
		switch (type)
		{
			case BackgroundType.COLOR:
				box_color.show_all();
				box_gradient.hide_all();
				box_image.hide_all();
				
				if (slide.background_color == null)
				{
					slide.background_color = Color.white;
				}
				slide.background_type = BackgroundType.COLOR;
				
				bg_color.set_color(slide.background_color.gdk);
				
				slide.changed(slide);
				
				break;
			
			case BackgroundType.GRADIENT:
				box_color.hide_all();
				box_gradient.show_all();
				box_image.hide_all();
				
				if (slide.background_gradient == null)
				{
					slide.background_gradient = new Gradient(Color.black,
					                                         Color.white);
					gradient_type.set_active(slide.background_gradient.mode);
				}
				slide.background_type = BackgroundType.GRADIENT;
				
				grad_color1.set_color(slide.background_gradient.start.gdk);
				grad_color2.set_color(slide.background_gradient.end.gdk);
				
				slide.changed(slide);
				
				break;
			
			case BackgroundType.IMAGE:
				box_color.hide_all();
				box_gradient.hide_all();
				box_image.show_all();
				
				slide.background_type = BackgroundType.IMAGE;
				if (slide.background_image_source != null)
				{
					bg_image.set_filename(slide.background_image_source);
				}
				else
				{
					bg_image.unselect_all();
				}
				
				slide.changed(slide);
				
				break;
		}
	}
}

