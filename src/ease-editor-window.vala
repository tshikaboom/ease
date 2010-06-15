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
 * An EditorWindow contains several widgets: a {@link MainToolbar}, an
 * {@link EditorEmbed}, a {@link SlideButtonPanel}, and assorted other
 * controls. The window is linked to a {@link Document}, and all changes
 * are made directly to that object.
 */
public class Ease.EditorWindow : Gtk.Window
{
	/**
	 * The {@link EditorEmbed} associated with this EditorWindow.
	 */ 
	public EditorEmbed embed;
	
	/**
	 * The {@link MainToolbar} of this EditorWindow.
	 */
	public MainToolbar main_toolbar;
	
	/**
	 * The {@link SlideButtonPanel} of this EditorWindow.
	 */
	public SlideButtonPanel slide_button_panel;
	
	/**
	 * A {@link ZoomSlider} at the bottom of the window, controlling the zoom
	 * level of the {@link EditorEmbed}.
	 */
	public ZoomSlider zoom_slider;

	/**
	 * A {@link Player} for the {@link Document} displayed in this window.
	 */
	private Player player;
	
	/**
	 * The {@link Document} associated with this EditorWindow.
	 */
	public Document document;
	
	/**
	 * The currently selected and displayed {@link Slide}.
	 */
	public Slide slide;
	
	/**
	 * The {@link Inspector} for this window.
	 */
	private Inspector inspector;
	
	/**
	 * The {@link UndoController} for this window.
	 */
	private UndoController undo;
	
	/**
	 * If the {@link Inspector} is visible.
	 */
	public bool inspector_shown { get; set; }
	
	/**
	 * If the {@link SlideButtonPanel} is visible.
	 */
	public bool slides_shown { get; set; }
	
	/**
	 * The zoom levels for the {@link ZoomSlider}
	 */
	private int[] ZOOM_LEVELS = {10, 25, 33, 50, 66, 75, 100, 125, 150,
	                             200, 250, 300, 400};

	/**
	 * Creates a new EditorWindow.
	 * 
	 * An EditorWindow includes a {@link MainToolbar}, an
	 * {@link EditorEmbed}, a {@link SlidePane}, a menu bar, and other
	 * interface elements.
	 *
	 * @param node The initial XML node to begin with.
	 */
	public EditorWindow(Document doc)
	{
		title = "Ease";
		set_default_size(1024, 768);
		
		document = doc;
		
		// slide display
		slide_button_panel = new SlideButtonPanel(document, this);
		
		// undo controller
		undo = new UndoController();
		
		// the inspector
		inspector = new Inspector();
		
		// main editor
		embed = new EditorEmbed(document, this);
		
		// assemble middle contents			
		var hbox = new Gtk.HBox(false, 0);
		hbox.pack_start(slide_button_panel, false, false, 0);
		hbox.pack_start(embed, true, true, 0);
		hbox.pack_start(inspector, false, false, 0);
		
		// assemble window contents
		var vbox = new Gtk.VBox(false, 0);
		vbox.pack_start(create_menu_bar(), false, false, 0);
		main_toolbar = new MainToolbar();
		vbox.pack_start(main_toolbar, false, false, 0);
		vbox.pack_start(hbox, true, true, 0);
		vbox.pack_end(create_bottom_bar(), false, false, 0);
		
		// final window setup
		add(vbox);
		show_all();
		embed.show();
		inspector.hide();
		inspector_shown = false;
		slides_shown = true;
		
		// USER INTERFACE SIGNALS
		
		// toolbar
		
		// create new slides
		main_toolbar.new_slide.clicked.connect(() => {
			var master = document.theme.slide_by_title(slide.title);
			
			var slide = new Slide.from_master(master, document,
			                                  document.width,
			                                  document.height, true);
			
			var index = document.index_of(slide) + 1;
			
			document.add_slide(index, slide);
			slide_button_panel.add_slide(index, slide);
		});
		
		// show and hide inspector
		main_toolbar.inspector.clicked.connect(() => {
			if (inspector_shown)
			{
				inspector.hide();
			}
			else
			{
				inspector.show();
			}
			inspector_shown = !inspector_shown;
		});
		
		// show and hide slides
		main_toolbar.slides.clicked.connect(() => {
			if (slides_shown)
			{
				slide_button_panel.hide();
			}
			else
			{
				slide_button_panel.show();
			}
			slides_shown = !slides_shown;
		});

		// make a new presentation
		main_toolbar.new_presentation.clicked.connect(Main.show_welcome);

		// open a file
		main_toolbar.open.clicked.connect(() => OpenDialog.run());
		
		// save file
		main_toolbar.save.clicked.connect(() => {
			if (document.filename == null)
			{
				var dialog =
					new Gtk.FileChooserDialog(_("Save Document"),
		        	                          null,
		        	                          Gtk.FileChooserAction.SAVE,
		        	                          "gtk-cancel",
		        	                          Gtk.ResponseType.CANCEL,
		        	                          "gtk-open",
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
					return;
				}
				dialog.destroy();
			}
		
			try { JSONParser.document_write(document); }
			catch (GLib.Error e)
			{
				error_dialog(_("Error Saving Document"), e.message);
			}
		});
		
		// play presentation
		main_toolbar.play.clicked.connect(() => {
			player = new Player(document);
		});
		
		// undo and redo
		main_toolbar.undo.clicked.connect(() => {
			undo.undo();
			update_undo();
			embed.slide_actor.relayout();
			embed.reposition_group();
		});
		
		main_toolbar.redo.clicked.connect(() => {
			undo.redo();
			update_undo();
			embed.slide_actor.relayout();
			embed.reposition_group();
		});
		
		// TODO: export HTML in a proper place
		main_toolbar.fonts.clicked.connect(() => {
			document.export_to_html(this);
		});
		
		main_toolbar.pdf.clicked.connect(() => {
			PDFExporter.export(document, this);
		});
		
		// change the embed's zoom when the zoom slider is moved
		zoom_slider.value_changed.connect(() => {
			embed.zoom = (float)zoom_slider.get_value() / 100f;
		});

		hide.connect(() => Main.remove_window(this));
		
		load_slide(0);
		update_undo();
	}
	
	/**
	 * Load a slide into the main {@link EditorEmbed}.
	 *
	 * @param filename The index of the slide.
	 */
	public void load_slide(int index)
	{
		slide = document.slides.get(index);
		
		// update ui elements for this new slide
		inspector.slide = slide;
		embed.set_slide(slide);
	}
	
	/**
	 * Add the most recent action to the {@link UndoController}.
	 *
	 * @param action The new {@link UndoAction}.
	 */
	public void add_undo_action(UndoAction action)
	{
		undo.add_action(action);
		undo.clear_redo();
		update_undo();
	}
	
	/**
	 * Updates the undo and redo items, enabling and disabling them as is
	 * applicable.
	 */
	private void update_undo()
	{
		main_toolbar.undo.sensitive = undo.can_undo();
		main_toolbar.redo.sensitive = undo.can_redo();
	}
	
	// signal handlers
	
	// menu bar creation
	private Gtk.MenuBar create_menu_bar()
	{
		var menubar = new Gtk.MenuBar();
		
		menubar.append(create_file_menu());
		menubar.append(create_help_menu());
		
		return menubar;
	}
	
	private Gtk.MenuItem create_file_menu()
	{
		/* TODO : use mnemonics */
		var menu_item = new Gtk.MenuItem.with_label(_("File"));
		var menu = new Gtk.Menu();
		
		var new_item = new Gtk.MenuItem.with_label(_("New"));
		var new_menu = new Gtk.Menu();
		var new_pres = new Gtk.MenuItem.with_label(_("Presentation"));
		new_pres.activate.connect(Main.show_welcome);
		var new_theme = new Gtk.MenuItem.with_label(_("Theme"));
		var quit = new Gtk.MenuItem.with_label(_("Quit"));
		quit.activate.connect(Gtk.main_quit);

		new_menu.append(new_pres);
		new_menu.append(new_theme);
		new_item.set_submenu(new_menu);
		menu.append(new_item);
		
		var open_item = new Gtk.MenuItem.with_label(_("Open"));
		open_item.activate.connect(() => OpenDialog.run());
		open_item.set_accel_path("<-Document>/File/Open");
		Gtk.AccelMap.add_entry("<-Document>/File/Open",
		                       Gdk.keyval_from_name("o"),
		                       Gdk.ModifierType.CONTROL_MASK);
		menu.append(open_item);
		menu.append(quit);
		menu_item.set_submenu(menu);
		
		return menu_item;
	}
	
	private Gtk.MenuItem create_help_menu()
	{
		var menu_item = new Gtk.MenuItem.with_label(_("Help"));
		var menu = new Gtk.Menu();
		
		var about = new Gtk.MenuItem.with_label(_("About Ease"));
		about.activate.connect(() => {
			var dialog = new AboutDialog();
			dialog.run();
			dialog.destroy();
		});

		menu.append(about);
		
		menu_item.set_submenu(menu);
		
		return menu_item;
	}
	
	private Gtk.Alignment create_bottom_bar()
	{
		var hbox = new Gtk.HBox(false, 5);
		
		// create zoom slider
		zoom_slider = new ZoomSlider(new Gtk.Adjustment(100, 10, 400, 10,
		                                                50, 50), ZOOM_LEVELS);
		zoom_slider.width_request = 200;
		zoom_slider.value_pos = Gtk.PositionType.RIGHT;
		zoom_slider.digits = 0;
		
		// put it all together
		hbox.pack_start(zoom_slider, false, false, 0);
		
		var vbox = new Gtk.VBox(false, 0);
		vbox.pack_start(hbox, true, true, 2);
		
		var align = new Gtk.Alignment(1, 1, 1, 1);
		align.add(vbox);
		return align;
	}
}

