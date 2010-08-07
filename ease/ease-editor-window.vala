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
 * A window for editing an Ease {@link Document}
 *
 * An EditorWindow contains several widgets: a toolbar, an
 * {@link EditorEmbed}, a {@link SlideButtonPanel}, and assorted other
 * controls. The window is linked to a {@link Document}, and all changes
 * are made directly to that object.
 */
internal class Ease.EditorWindow : Gtk.Window
{
	/**
	 * The {@link EditorEmbed} associated with this EditorWindow.
	 */ 
	internal EditorEmbed embed;
	
	/**
	 * The {@link SlideButtonPanel} of this EditorWindow.
	 */
	internal SlideButtonPanel slide_button_panel;
	
	/**
	 * A {@link ZoomSlider} at the bottom of the window, controlling the zoom
	 * level of the {@link EditorEmbed}.
	 */
	internal ZoomSlider zoom_slider;

	/**
	 * A {@link Player} for the {@link Document} displayed in this window.
	 */
	private Player player;
	
	/**
	 * The {@link Document} associated with this EditorWindow.
	 */
	internal Document document;
	
	/**
	 * The currently selected and displayed {@link Slide}.
	 */
	internal Slide slide;
	
	/**
	 * The {@link Inspector} for this window.
	 */
	private Inspector inspector;
	
	/**
	 * The main editor widget (embed, inspector, and slide thumbnails)
	 */
	private Gtk.Widget editor;
	
	/**
	 * The {@link SlideSorter} for this window.
	 */
	private SlideSorter sorter;
	
	/**
	 * The container for the editor or the SlideSorter.
	 */
	private Gtk.Bin main_bin;
	
	/**
	 * The {@link UndoController} for this window.
	 */
	private UndoController undo;
	
	/**
	 * Space to temporarily cache an {@link UndoAction}.
	 */
	private UndoAction undo_action;
	
	/**
	 * The undo button.
	 */
	private Gtk.ToolButton undo_button;
	
	/**
	 * The redo button.
	 */
	private Gtk.ToolButton redo_button;
	
	/**
	 * If the {@link SlideButtonPanel} is visible.
	 */
	internal bool slides_shown { get; set; }
	
	/**
	 * The color selection dialog for this window.
	 */
	private Gtk.ColorSelectionDialog color_dialog;
	
	/**
	 * The color selection dialog's widget.
	 */
	private Gtk.ColorSelection color_selection;
	
	/**
	 * The Editor radio button.
	 */
	private Gtk.RadioMenuItem show_editor;
	
	/**
	 * The Editor radio button.
	 */
	private Gtk.RadioMenuItem show_sorter;
	
	/**
	 * The time the document was last saved.
	 */
	long last_saved = 0;
	
	/**
	 * The zoom levels for the {@link ZoomSlider}
	 */
	private int[] ZOOM_LEVELS = {10, 25, 33, 50, 66, 75, 100, 125, 150,
	                             200, 250, 300, 400};
	
	private const string UI_FILE_PATH = "editor-window.ui";
	
	private const string FONT_TEXT =
		_("The quick brown fox jumps over the lazy dog");

	/**
	 * Creates a new EditorWindow.
	 * 
	 * An EditorWindow includes a toolbar, an
	 * {@link EditorEmbed}, a {@link InspectorSlidePane}, a menu bar, and other
	 * interface elements.
	 *
	 * @param node The initial XML node to begin with.
	 */
	internal EditorWindow(Document doc)
	{
		title = "Ease";
		set_default_size(1024, 768);
		
		document = doc;
		document.undo.connect(add_undo_action);
		
		var builder = new Gtk.Builder();
		try
		{
			builder.add_from_file(data_path(Path.build_filename(Temp.UI_DIR,
				                                                UI_FILE_PATH)));
		}
		catch (Error e) { error("Error loading UI: %s", e.message); }
		
		builder.connect_signals(this);
		add(builder.get_object("Editor Widget") as Gtk.VBox);
		main_bin = builder.get_object("main-align") as Gtk.Bin;
		editor = builder.get_object("editor") as Gtk.Widget;
		show_sorter =
			builder.get_object("slide-sorter-radio") as Gtk.RadioMenuItem;
		show_editor =
			builder.get_object("editor-radio") as Gtk.RadioMenuItem;
				
		// slide display
		slide_button_panel = new SlideButtonPanel(document, this);
		(builder.get_object("Slides Align") as Gtk.Alignment).
			add(slide_button_panel);
		
		// undo controller
		undo = new UndoController();
		undo_button = builder.get_object("Undo") as Gtk.ToolButton;
		redo_button = builder.get_object("Redo") as Gtk.ToolButton;
		
		// main editor
		embed = new EditorEmbed(document, this);
		(builder.get_object("Embed Align") as Gtk.Alignment).add(embed);
		embed.undo.connect(add_undo_action);
		
		// the inspector
		inspector = new Inspector(document);
		(builder.get_object("Inspector Align") as Gtk.Alignment).add(inspector);
		embed.element_selected.connect(
			inspector.element_pane.on_element_selected);
		embed.element_deselected.connect(
			inspector.element_pane.on_element_deselected);
		
		// zoom slider
		(builder.get_object("Zoom Slider Item") as Gtk.ToolItem).
			add(create_zoom_slider());
		
		// add slide menu
		var menu = builder.get_object("add-slide-menu") as Gtk.MenuShell;
		
		foreach (var master in Theme.MASTER_SLIDES)
		{
			var item = new Gtk.MenuItem.with_mnemonic(
				Theme.master_mnemonic_description(master));
			menu.append(item);
			
			item.activate.connect(on_new_slide_menu);
		}
		menu.show_all();
		
		// final window setup
		slide_button_panel.show_all();
		embed.show_all();
		show();
		inspector.hide();
		slides_shown = true;
		
		// register the accelerator group
		add_accel_group(builder.get_object("accel-group") as Gtk.AccelGroup);
		
		// close the window
		delete_event.connect((sender, event) => {
			if (last_saved == 0) return false;
			
			var name = document.filename == null ? _("Untitled Document") :
			                                       document.filename;
			var time_diff = (int)(time_t() - last_saved);
			
			var dialog = new CloseConfirmDialog(name, time_diff);
			var response = dialog.run();
			dialog.destroy();
			
			if (response == Gtk.ResponseType.CANCEL) return true;
			if (response == Gtk.ResponseType.NO)
			{
				Main.remove_window(this);
				return false;
			}
			
			// otherwise, save and quit
			var result = !save_document(null);
			if (!result) Main.remove_window(this);
			return result;
		});
		
		set_slide(0);
		update_undo();
	}
	
	/**
	 * Load a slide into the main {@link EditorEmbed}.
	 *
	 * @param filename The index of the slide.
	 */
	internal void set_slide(int index)
	{
		slide = document.get_slide(index);
		
		// update ui elements for this new slide
		inspector.slide = slide;
		embed.set_slide(slide);
	}
	
	/**
	 * Add the most recent action to the {@link UndoController}.
	 *
	 * @param action The new {@link UndoItem}.
	 */
	internal void add_undo_action(UndoItem action)
	{
		undo.add_action(action);
		undo.clear_redo();
		update_undo();
		
		// the document has been edited, first change at this time
		if (last_saved == 0)
		{
			last_saved = time_t();
		}
	}
	
	/**
	 * Updates the undo and redo items, enabling and disabling them as is
	 * applicable.
	 */
	private void update_undo()
	{
		undo_button.sensitive = undo.can_undo();
		redo_button.sensitive = undo.can_redo();
	}
	
	// signal handlers
	[CCode (instance_pos = -1)]
	internal void on_quit(Gtk.Widget sender)
	{
		Gtk.main_quit ();
	}
	
	[CCode (instance_pos = -1)]
	internal void on_delete(Gtk.Widget sender)
	{
		if (embed.selected == null) return;
		
		var i = slide.index_of(embed.selected.element);
		slide.remove_at(i);
	}

	[CCode (instance_pos = -1)]
	internal void new_slide_handler(Gtk.Widget? sender)
	{
		var s = document.theme.create_slide(document.DEFAULT_SLIDE,
		                                    slide.width,
		                                    slide.height);
		
		var index = document.index_of(slide) + 1;
		
		document.add_slide(index, s);
	}
	
	[CCode (instance_pos = -1)]
	internal void on_new_slide_menu(Gtk.Widget? sender)
	{
		var item = sender as Gtk.MenuItem;
		var s = document.theme.create_slide(
			Theme.master_from_description(item.get_label()),
			slide.width, slide.height);
		
		var index = document.index_of(slide) + 1;
		
		document.add_slide(index, s);
	}
	
	[CCode (instance_pos = -1)]
	internal void remove_slide(Gtk.Widget? sender)
	{
		// don't remove the last slide in a document
		if (document.length < 2) return;
		
		// if the sorter isn't set to null, it must be active
		if (sorter != null)
		{
			var s = sorter.delete_slide();
			if (s != null) slide_button_panel.select_slide(s);
			return;
		}
		
		// set the slide to something safe
		slide_button_panel.select_slide(document.remove_slide(slide));
	}
	
	[CCode (instance_pos = -1)]
	internal void play_handler(Gtk.Widget sender)
	{		
		player = new Player(document);
		
		player.complete.connect(() => {
			player = null;
			show();
			present();
		});
		
		hide();
	}
	
	[CCode (instance_pos = -1)]
	internal void undo_handler(Gtk.Widget sender)
	{
		undo.undo();
		update_undo();
		embed.slide_actor.relayout();
		embed.reposition_group();
	}
	
	[CCode (instance_pos = -1)]
	internal void redo_handler(Gtk.Widget sender)
	{
		undo.redo();
		update_undo();
		embed.slide_actor.relayout();
		embed.reposition_group();
	}
	
	[CCode (instance_pos = -1)]
	internal void insert_text(Gtk.Widget sender)
	{
		var text = document.theme.create_custom_text();
		text.x = slide.width / 2 - text.width / 2;
		text.y = slide.height / 2 - text.height / 2;
		slide.append(text);
		embed.select_element(text);
	}
	
	[CCode (instance_pos = -1)]
	internal void insert_image(Gtk.Widget sender)
	{
		var dialog = new Gtk.FileChooserDialog(_("Insert Image"),
		                                       null,
		                                       Gtk.FileChooserAction.OPEN,
		                                       "gtk-cancel",
		                                       Gtk.ResponseType.CANCEL,
		                                       "gtk-open",
		                                       Gtk.ResponseType.ACCEPT);

		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			try
			{
				var img = new Clutter.Texture.from_file(dialog.get_filename());
				var e = new ImageElement();
				
				// set the size and position of the element
				int width = 0, height = 0;
				img.get_base_size(out width, out height);
				
				e.width = width;
				e.height = height;
				e.x = slide.width / 2 - width / 2;
				e.y = slide.height / 2 - height / 2;
				
				e.element_type = Slide.IMAGE_TYPE;
				e.identifier = Theme.CUSTOM_MEDIA;
				e.filename = document.add_media_file(dialog.get_filename());
				e.source_filename = dialog.get_filename();
				
				// add the element
				slide.append(e);
				embed.select_element(e);
			}
			catch (Error e)
			{
				error_dialog(_("Error Inserting Image"), e.message);
			}
		}
		dialog.destroy();
	}
	
	[CCode (instance_pos = -1)]
	internal void insert_video(Gtk.Widget sender)
	{
		var dialog = new Gtk.FileChooserDialog(_("Insert Video"),
		                                       null,
		                                       Gtk.FileChooserAction.OPEN,
		                                       "gtk-cancel",
		                                       Gtk.ResponseType.CANCEL,
		                                       "gtk-open",
		                                       Gtk.ResponseType.ACCEPT);

		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			try
			{
				var e = new VideoElement();
				
				// TODO: find the actual size of the video
				e.width = 640;
				e.height = 480;
				e.x = slide.width / 2 - e.width / 2;
				e.y = slide.height / 2 - e.height / 2;
				
				e.element_type = Slide.VIDEO_TYPE;
				e.identifier = Theme.CUSTOM_MEDIA;
				e.filename = document.add_media_file(dialog.get_filename());
				e.source_filename = dialog.get_filename();
				
				// add the element
				slide.append(e);
				embed.select_element(e);
			}
			catch (Error e)
			{
				error_dialog(_("Error Inserting Video"), e.message);
			}
		}
		dialog.destroy();
	}
	
	[CCode (instance_pos = -1)]
	internal void on_insert_rectangle(Gtk.Widget sender)
	{
		var rect = new ShapeElement(ShapeType.RECTANGLE);
		rect.width = 400;
		rect.height = 300;
		rect.x = document.width / 2 - rect.width / 2;
		rect.y = document.height / 2 - rect.height / 2;
		slide.append(rect);
		embed.select_element(rect);
	}
	
	[CCode (instance_pos = -1)]
	internal void on_insert_oval(Gtk.Widget sender)
	{
		var oval = new ShapeElement(ShapeType.OVAL);
		oval.width = 300;
		oval.height = 300;
		oval.x = document.width / 2 - oval.width / 2;
		oval.y = document.height / 2 - oval.height / 2;
		slide.append(oval);
		embed.select_element(oval);
	}
	
	[CCode (instance_pos = -1)]
	internal void set_view(Gtk.Widget sender)
	{
		if (show_editor == sender)
		{
			if (main_bin.get_child() == editor) return;
			main_bin.remove(sorter);
			main_bin.add(editor);
			sorter = null;
		}
		else if (show_sorter == sender)
		{
			if (sorter == null) sorter = new SlideSorter(document);
			if (main_bin.get_child() == sorter) return;
			main_bin.remove(editor);
			main_bin.add(sorter);
			sorter.show_all();
			
			// when a slide is clicked in the sorter, switch back here
			sorter.display_slide.connect((s) => {
				set_slide(document.index_of(s));
				show_editor.active = true;
			});
		}
	}
	
	[CCode (instance_pos = -1)]
	internal void zoom_in(Gtk.Widget sender)
	{
		zoom_slider.zoom_in();
	}
	
	[CCode (instance_pos = -1)]
	internal void zoom_out(Gtk.Widget sender)
	{
		zoom_slider.zoom_out();
	}
	
	[CCode (instance_pos = -1)]
	internal bool save_document(Gtk.Widget? sender)
	{
		if (document.filename == null)
		{
			var dialog =
				new Gtk.FileChooserDialog(_("Save Document"),
	        	                          null,
	        	                          Gtk.FileChooserAction.SAVE,
	        	                          "gtk-cancel",
	        	                          Gtk.ResponseType.CANCEL,
	        	                          "gtk-save",
	        	                          Gtk.ResponseType.ACCEPT, null);
	        
	        var filter = new Gtk.FileFilter();
			filter.add_pattern("*.ease");
			dialog.filter = filter;

			if (dialog.run() == Gtk.ResponseType.ACCEPT)
			{
				document.filename = dialog.get_filename();
			}
			else
			{
				dialog.destroy();
				return false;
			}
			dialog.destroy();
		}
	
		try
		{
			document.to_json();
			last_saved = 0;
		}
		catch (GLib.Error e)
		{
			error_dialog(_("Error Saving Document"), e.message);
			return false;
		}
		return true;
	}
	
	// export menu
	[CCode (instance_pos = -1)]
	internal void export_as_pdf(Gtk.Widget sender)
	{
		document.export_as_pdf(this);
	}
	
	[CCode (instance_pos = -1)]
	internal void export_as_postscript(Gtk.Widget sender)
	{
		document.export_as_postscript(this);
	}
	
	[CCode (instance_pos = -1)]
	internal void export_as_html(Gtk.Widget sender)
	{
		document.export_as_html(this);
	}
	
	[CCode (instance_pos = -1)]
	internal void on_lower(Gtk.Widget sender)
	{
		if (embed.selected == null) return;
		slide.lower(embed.selected.element);
	}
	
	[CCode (instance_pos = -1)]
	internal void on_raise(Gtk.Widget sender)
	{
		if (embed.selected == null) return;
		slide.raise(embed.selected.element);
	}
	
	[CCode (instance_pos = -1)]
	internal void on_lower_bottom(Gtk.Widget sender)
	{
		if (embed.selected == null) return;
		slide.lower_bottom(embed.selected.element);
	}
	
	[CCode (instance_pos = -1)]
	internal void on_raise_top(Gtk.Widget sender)
	{
		if (embed.selected == null) return;
		slide.raise_top(embed.selected.element);
	}
	
	[CCode (instance_pos = -1)]
	internal void inspector_clicked_handler(Gtk.Widget? sender)
	{	
		if (inspector.visible)
		{
			inspector.hide();
		}
		else
		{
			inspector.show();
		}
	}
	
	[CCode (instance_pos = -1)]
	internal void show_color_dialog(Gtk.Widget sender)
	{
		// if nothing is selected, don't display the dialog
		if (embed.selected == null) return;
		
		// if the dialog is already displayed, don't create another
		if (color_dialog != null)
		{
			color_dialog.present();
			return;
		}
		
		// store the original color in case the user cancels	
		var original_color = embed.selected.element.get_color();
		
		// create an UndoAction for potential use
		undo_action = new UndoAction(embed.selected.element, "color");
		
		// create the dialog
		color_dialog = new Gtk.ColorSelectionDialog(_("Select Color"));
		color_selection = color_dialog.color_selection as Gtk.ColorSelection;
		
		// update the color of the element
		color_selection.color_changed.connect(color_dialog_changed);
		
		// update the color dialog if the element changes
		embed.notify["selected"].connect(color_dialog_selection);
		
		// clean up when the dialog is hidden
		color_dialog.hide.connect(() => {
			embed.notify["selected"].disconnect(color_dialog_selection);
			color_selection.color_changed.disconnect(color_dialog_changed);
			color_dialog.destroy();
			color_dialog = null;
		});
		
		// hide the dialog when the ok button is clicked
		(color_dialog.ok_button as Gtk.Button).clicked.connect(() => {
			color_dialog.hide();
			
			// if the color was changed, add the UndoAction
			if (original_color != embed.selected.element.get_color())
			{
				add_undo_action(undo_action);
			}
		});
		
		// reset the original color and hide the dialog when cancel is clicked
		(color_dialog.cancel_button as Gtk.Button).clicked.connect(() => {
			embed.selected.element.set_color(original_color);
			color_dialog.hide();
		});
		
		// cancel when the dialog is closed
		color_dialog.close.connect(() => {
			color_dialog.cancel_button.activate();
		});
		
		// make the dialog modal for the window
		color_dialog.set_transient_for(this);
		color_dialog.modal = true;
		
		// run the dialog
		color_dialog.run();
	}
	
	private void color_dialog_changed(Gtk.ColorSelection sender)
	{
		embed.set_element_color(Transformations.gdk_color_to_clutter_color(
		                        sender.current_color));
		slide.changed(slide);
	}
	
	private void color_dialog_selection(Object sender, ParamSpec spec)
	{
		var color = (sender as EditorEmbed).selected.element.get_color();
		if (color == null) return;
		
		color_selection.current_color =
			Transformations.clutter_color_to_gdk_color(color);
	}
	
	[CCode (instance_pos = -1)]
	internal void select_font(Gtk.Widget? sender)
	{
		// create a font selection dialog
		var font_selection = new Gtk.FontSelectionDialog(_("Select Font"));
		
		// grab the selected element, classes as TextElement
		var text = embed.selected.element as TextElement;
		
		// set the preview text to the element's text, if none, use preview text
		font_selection.set_preview_text(text.text != "" ?
		                                text.text : FONT_TEXT);
		
		// set the dialog's font to the current font
		font_selection.set_font_name(text.font_description.to_string());
		
		// run the dialog
		switch (font_selection.run())
		{
			case Gtk.ResponseType.OK:
				// allow the user to undo the font change
				add_undo_action(
					new UndoAction(embed.selected.element, "font-description"));
				
				// set the font description to the new font
				text.font_description = 
					Pango.FontDescription.from_string(
						font_selection.get_font_name());
						
				// emit the "changed" signal on the element's slide
				text.changed();
				break;
		}
		
		font_selection.destroy();
	}
	
	private ZoomSlider create_zoom_slider()
	{
		// create zoom slider
		zoom_slider = new AnimatedZoomSlider(new Gtk.Adjustment(100, 10, 400,
		                                                        10, 50, 50),
		                                                        ZOOM_LEVELS);
		zoom_slider.width_request = 200;
		zoom_slider.value_pos = Gtk.PositionType.RIGHT;
		zoom_slider.digits = 0;
		
		zoom_slider.value_changed.connect(() => {
			embed.zoom = (float)zoom_slider.get_value() / 100f;
		});
		
		zoom_slider.show_all();
		
		return zoom_slider;
	}
}
