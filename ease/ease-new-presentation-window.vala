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
 * The window shown when Ease starts and when the user creates a new
 * presentation.
 */
internal class Ease.NewPresentationWindow : Gtk.Window
{
	// main buttons
	private Gtk.Button new_pres_button;
	private Gtk.Button open_pres_button;
	private Gtk.ComboBox combores;
	private Gtk.SpinButton x_res;
	private Gtk.SpinButton y_res;
	
	// zoom widgets
	private ZoomSlider zoom_slider;

	// clutter view
	private ScrolledEmbedWindow scrolled;
	
	// icon view that displays slide previews
	private IconView icon_view;
	
	// store for the previews and slides
	private IterableListStore model;
	private const int THEME_COL = 0;
	private const int TEXT_COL = 1;
	private const int PIXBUF_COL = 2;
	
	/**
	 * The currently selected Theme.
	 */
	private Theme selected_theme = null;
	
	/**
	 * The slide identifier to display as a preview.
	 */
	private const string PREVIEW_SLIDE = Theme.TITLE;
	
	/**
	 * The set of resolutions to display in a combo box. Of course, the user is
	 * free to specify a custom resolution with the spin buttons.
	 */
	private static int[] RESOLUTIONS_X = { 640, 800, 1024, 1280, 1280, 1920 };
	private static int[] RESOLUTIONS_Y = { 480, 600,  768,  720, 1024, 1080 };
	
	/**
	 * The index of the default resolution in {@link RESOLUTIONS_X} (and y).
	 */
	private const int DEFAULT_RESOLUTION = 2;
	
	/**
	 * The number of resolutions in {@link RESOLUTIONS_X} (and y).
	 */
	private const int RESOLUTION_COUNT = 6;
	
	/**
	 * The values that the animated zoom slider will animate to when its
	 * buttons are clicked.
	 */
	private int[] ZOOM_VALUES = {100, 150, 200, 250, 400};
	
	/**
	 * The starting point for the zoom slider.
	 */
	private const int SLIDER_START = 190;
	
	/**
	 * The amount of space displayed around and between items of the icon view
	 * that displays the available themes.
	 */
	private const int ICON_PADDING = 15;
	
	/**
	 * The slide to use for theme previews.
	 */
	private const string PREVIEW_ID = Theme.TITLE;
	
	internal NewPresentationWindow()
	{
		title = _("New Presentation");
		set_default_size(640, 480);
		
		var builder = new Gtk.Builder();
		try
		{
			string ui_path =
				data_path(Path.build_filename(Temp.UI_DIR,
				                              "new-presentation-window.ui"));
			builder.add_from_file(ui_path);
		}
		catch (Error e)
		{
			critical("Unable to load UI: %s", e.message);
		}

		var vbox = builder.get_object("vbox1") as Gtk.VBox;
		var hbox = builder.get_object("hbox1") as Gtk.HBox;
		combores = builder.get_object("combo_resolution") as Gtk.ComboBox;
		x_res = builder.get_object("horiz_spin") as Gtk.SpinButton;
		y_res = builder.get_object("vert_spin") as Gtk.SpinButton;
		new_pres_button = builder.get_object("newpres") as Gtk.Button;
		open_pres_button = builder.get_object("openpres") as Gtk.Button;

		// zoom slider
		zoom_slider = new AnimatedZoomSlider(new Gtk.Adjustment(100, 100, 400,
		                                     10, 50, 50), ZOOM_VALUES);
		hbox.pack_start(zoom_slider, true, false, 0);
		hbox.reorder_child(zoom_slider, 4);
		zoom_slider.sliderpos = SLIDER_START;

		// Resolutions combo box
		// FIXME : not re-create it, or do it from Glade.
		hbox.remove(combores);
		combores = new Gtk.ComboBox.text();
		combores.insert_text(0, _("Custom"));
		for (var i = 0; i < RESOLUTION_COUNT; i++)
		{
			combores.append_text(_("%i by %i").printf(RESOLUTIONS_X[i],
			                                          RESOLUTIONS_Y[i]));
		}
		
		combores.changed.connect(() => {
			var val = combores.get_active();
			if (val > 0) {
				x_res.set_value(RESOLUTIONS_X[val - 1]);
				y_res.set_value(RESOLUTIONS_Y[val - 1]);
			}
		});

		hbox.pack_start(combores);
		hbox.reorder_child(combores, 0);

		// set the range of the resolution spin buttons
		x_res.set_range(RESOLUTIONS_X[0],
		                RESOLUTIONS_X[RESOLUTION_COUNT - 1]);

		y_res.set_range(RESOLUTIONS_Y[0],
		                RESOLUTIONS_Y[RESOLUTION_COUNT - 1]);
		
		// rebuild the preview thumbnails when resolution changes
		x_res.value_changed.connect(() => {
			reconstruct_previews((int)x_res.get_value(),
			                     (int)y_res.get_value());
		});

		y_res.value_changed.connect(() => {
			reconstruct_previews((int)x_res.get_value(),
			                     (int)y_res.get_value());
		});
		
		// select the default slide size, +1 to avoid "Custom"
		combores.set_active(DEFAULT_RESOLUTION + 1);

		// buttons
		new_pres_button.sensitive = false;
		new_pres_button.image = new Gtk.Image.from_stock("gtk-new",
														 Gtk.IconSize.BUTTON);
		
		// create the upper UI - the embed
		scrolled = new ScrolledEmbedWindow(null);
		scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
		(scrolled.embed.get_stage() as Clutter.Stage).use_fog = false;
		(scrolled.embed.get_stage() as Clutter.Stage).color = { 0, 0, 0, 255 };
		
		// create the icon view
		icon_view = new Ease.IconView();
		
		// icon view model columns
		icon_view.pixbuf_column = PIXBUF_COL;
		icon_view.text_column = TEXT_COL;
		
		// icon view styling
		icon_view.padding = ICON_PADDING;
		icon_view.column_spacing = ICON_PADDING;
		icon_view.row_spacing = ICON_PADDING;
		icon_view.item_width = (float)zoom_slider.get_value();
		icon_view.text_color = { 255, 255, 255, 255 };
		
		// icon view selection (single theme, no deselecting)
		icon_view.selection_mode = Gtk.SelectionMode.BROWSE;
		
		// add the icon view to the stage
		scrolled.embed.viewport.add_actor(icon_view);
		
		// enable the new button once the user selects a theme
		icon_view.selection_changed.connect(() => {
			new_pres_button.sensitive = true;
			
			// set the selected theme			
			icon_view.selected_foreach((v, path) => {
				Gtk.TreeIter itr;
				Theme theme;
				icon_view.model.get_iter(out itr, path);
				icon_view.model.get(itr, THEME_COL, out theme);
				selected_theme = theme;
			});
		});
		
		// create a new document of the selected theme when double clicked
		icon_view.item_activated.connect((v, path) => {
			// get the theme
			Gtk.TreeIter itr;
			Theme theme;
			icon_view.model.get_iter(out itr, path);
			icon_view.model.get(itr, THEME_COL, out theme);
			selected_theme = theme;
			
			// create the document
			create_new_document(null);
		});
		
		// add the themes
		try
		{
			// locate all installed theme directories
			var list = locate_themes();
			
			// create the model
			model = new IterableListStore({ typeof(Theme),
			                                typeof(string),
			                                typeof(Gdk.Pixbuf) });
			icon_view.model = model;
			
			// get an iterator to the start of the list
			Gtk.TreeIter iter;
			
			// add each theme to the model
			foreach (var path in list)
			{
				// load the theme
				var theme = new Theme(path);
				
				// append a row to the model for storage
				model.append(out iter);
				
				// store the theme, theme's name, and slide in the column
				model.set(iter, THEME_COL, theme,
				                TEXT_COL, theme.title);
				
				// create a pixbuf preview and store it in the model
				construct_preview((int)x_res.get_value(),
				                  (int)y_res.get_value(),
				                  ref iter);				                  
			}
		}
		catch (Error e)
		{
			error_dialog("Error loading themes: %s", e.message);
		}
		
		// place the clutter embed into the window
		vbox.pack_start(scrolled, true, true, 0);
		vbox.reorder_child(scrolled, 0);
		
		// automatically resize the icon view with the embed
		size_allocate.connect(() => {
			scrolled.embed.viewport.width = scrolled.embed.get_stage().width;
			icon_view.width = scrolled.embed.viewport.width;
		});
		
		// change the zoom of the previews when the zoom slider is moved
		zoom_slider.value_changed.connect(() => {
			icon_view.item_width = (float)zoom_slider.get_value();
		});

		// connect signals and build the window
		builder.connect_signals(this);
		add(vbox);
		show_all();
	}

	[CCode (instance_pos = -1)]
	internal void on_open_pres_button_clicked(Gtk.Widget sender)
	{
		var filename = Dialog.open_document(this);
		if (filename != null)
		{
			Main.open_file(filename);
			hide();
		}
	}

	[CCode (instance_pos = -1)]
	internal void create_new_document(Gtk.Widget? sender)
	{
		Main.new_from_theme(selected_theme,
		                    (int)x_res.get_value(),
		                    (int)y_res.get_value());
		hide();
	}
	
	private void set_resolution_box(int width, int height)
	{
		for (var i = 0; i < RESOLUTION_COUNT; i++)
		{
			if (width == RESOLUTIONS_X[i] && height == RESOLUTIONS_Y[i])
			{
				combores.set_active(i + 1);
				return;
			}
		}
		combores.set_active(0);
	}
		
	private extern const string DATA_DIR;
	private Gee.LinkedList<string> locate_themes() throws GLib.Error
	{
		var list = new Gee.LinkedList<string>();
		foreach (var item in data_contents_folder("themes"))
		{
			var f = File.new_for_path(Path.build_filename(item, "Theme.json"));
			if (f.query_exists(null) && theme_not_redundant(item, list))
			{
				list.add(item);
			}
		}
		return list;
	}
	
	// TODO: this isn't a very smart method. add versions to themes, check those
	private bool theme_not_redundant(string item, Gee.List<string> list)
	{
		foreach (var str in list)
		{
			if (File.new_for_path(str).get_basename() == 
			    File.new_for_path(item).get_basename())
				return false;
		}
		return true;
	}
	
	/**
	 * Creates a slide preview and saves it in the model's appropriate column.
	 */
	private void construct_preview(int width, int height, ref Gtk.TreeIter iter)
	{
		// get the theme
		Theme theme;
		model.get(iter, THEME_COL, out theme);
		
		// create the slide to be previewed
		var slide = theme.create_slide(PREVIEW_SLIDE,
		                               (int)x_res.get_value(),
		                               (int)y_res.get_value());
		
		// set the special text on the slide
		foreach (var element in slide)
		{
			element.has_been_edited = true;
			switch (element.identifier)
			{
				case Theme.TITLE_TEXT:
					(element as TextElement).text.clear_set(theme.title,
					                                        null);
					break;
				case Theme.AUTHOR_TEXT:
					(element as TextElement).text.clear_set(
						Environment.get_real_name(), null);
					break;
			}
		}
		
		// create the pixbuf
		var pixbuf = SlideButtonPanel.pixbuf_sized(slide, 500, width, height);
		
		// set the image
		model.set(iter, PIXBUF_COL, pixbuf);
	}
	
	/**
	 * Reconstructs all previews.
	 */
	private void reconstruct_previews(int width, int height)
	{
		debug("remake");
		foreach (var iter in model)
		{
			construct_preview(width, height, ref iter);
		}
	}
}
