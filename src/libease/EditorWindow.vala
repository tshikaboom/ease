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
	// interface elements
	public EditorEmbed embed;
	public MainToolbar main_toolbar;
	public Gtk.HBox inspector;
	public Gtk.HBox slides;
	public TransitionPane pane_transition;
	public SlidePane pane_slide;
	public Gtk.HScale zoom_slider;
	private Gtk.Button zoom_in;
	private Gtk.Button zoom_out;
	private int zoom_previous = 0;

	// the player for this window
	private Player player;
	
	public Document document;
	public Slide slide;
	
	// interface variables
	public bool inspector_shown { get; set; }
	public bool slides_shown { get; set; }
	
	// constants
	private const int[] ZOOM_LEVELS = {10, 25, 33, 50, 66, 75, 100, 125, 150, 200, 250, 300, 400};
	private const int ZOOM_COUNT = 13;

	/**
	 * Creates a new EditorWindow.
	 * 
	 * An EditorWindow includes a {@link MainToolbar}, an
	 * {@link EditorEmbed}, a {@link SlidePane}, a menu bar, and other
	 * interface elements.
	 *
	 * @param node The initial XML node to begin with.
	 */
	public EditorWindow(string filename)
	{
		title = "Ease - " + filename;
		set_default_size(1024, 768);
		
		document = new Document.from_file(filename);
		
		// slide display
		var slides_win = new SlideButtonPanel(document, this);
		
		// the inspector
		inspector = new Gtk.HBox(false, 0);
		var notebook = new Gtk.Notebook();
		notebook.scrollable = true;
		pane_transition = new TransitionPane();
		pane_slide = new SlidePane();
		notebook.append_page(pane_slide,
		                     new Gtk.Image.from_stock("gtk-page-setup",
		                                              Gtk.IconSize.SMALL_TOOLBAR));
		notebook.append_page(pane_transition,
		                     new Gtk.Image.from_stock("gtk-media-forward",
		                                              Gtk.IconSize.SMALL_TOOLBAR));
		inspector.pack_start(notebook, false, false, 0);
		
		// main editor
		embed = new EditorEmbed(document);
		
		// assemble middle contents			
		var hbox = new Gtk.HBox(false, 0);
		var hpaned = new Gtk.HPaned();
		hpaned.pack1(slides_win, false, false);
		hpaned.pack2(embed, true, true);
		hbox.pack_start(hpaned, true, true, 0);
		hbox.pack_start(inspector, false, false, 0);
		
		// assemble window contents
		var vbox = new Gtk.VBox(false, 0);
		vbox.pack_start(create_menu_bar(), false, false, 0);
		main_toolbar = new MainToolbar();
		vbox.pack_start(main_toolbar, false, false, 0);
		vbox.pack_start(new Gtk.HSeparator(), false, false, 0);
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
				slides.hide();
			}
			else
			{
				slides.show();
			}
			slides_shown = !slides_shown;
		});

		// make a new presentation
		main_toolbar.new_presentation.clicked.connect(Main.show_welcome);

		// open a file
		main_toolbar.open.clicked.connect(() => OpenDialog.run());
		
		// save file
		main_toolbar.save.clicked.connect(() => {
			document.to_file();
		});
		
		// play presentation
		main_toolbar.play.clicked.connect(() => {
			player = new Player(document);
		});
		
		// TODO: export HTML in a proper place
		main_toolbar.fonts.clicked.connect(() => {
			document.export_to_html(this);
		});
		
		// inspector
		
		// transition pane
		pane_transition.effect.changed.connect(() => {
			var variants = Transitions.get_variants(pane_transition.effect.active);
			pane_transition.variant_align.remove(pane_transition.variant);
			pane_transition.variant = new Gtk.ComboBox.text();
			pane_transition.variant_align.add(pane_transition.variant);
			pane_transition.variant.show();
			pane_transition.variant.changed.connect(() => {
				slide.variant = Transitions.get_variants(pane_transition.effect.active)[pane_transition.variant.active];
			});
			var variant_count = Transitions.get_variant_count(pane_transition.effect.active);
			if (variant_count > 0)
			{
				for (var i = 0; i < variant_count; i++)
				{
					pane_transition.variant.append_text(variants[i]);
				}
				pane_transition.variant.set_active(0);
				slide.variant = Transitions.get_variants(pane_transition.effect.active)[pane_transition.variant.active];
			}
			slide.transition = Transitions.get_name(pane_transition.effect.active);
		});
		
		pane_transition.start_transition.changed.connect(() => {
			if (pane_transition.start_transition.active == 0)
			{
				pane_transition.delay.sensitive = false;
			}
			else
			{
				pane_transition.delay.sensitive = true;
			}
		});
		
		// change the embed's zoom when the zoom slider is moved
		zoom_slider.change_value.connect((scroll, zoom, user_data) => {
			if (zoom_previous != (float)zoom_slider.get_value())
			{
				embed.set_zoom((float)zoom_slider.get_value());
			}
			zoom_previous = zoom;
			return false;
		});
		
		// zoom in and out with the buttons
		zoom_in.clicked.connect(() => {
			for (var i = 0; i < ZOOM_COUNT; i++)
			{
				if (zoom_slider.get_value() < ZOOM_LEVELS[i])
				{
					zoom_slider.set_value(ZOOM_LEVELS[i]);
					embed.set_zoom(ZOOM_LEVELS[i]);
					zoom_previous = ZOOM_LEVELS[i];
					break;
				}
			}
		});
		
		zoom_out.clicked.connect(() => {
			for (var i = ZOOM_COUNT - 1; i > -1; i--)
			{
				if (zoom_slider.get_value() > ZOOM_LEVELS[i])
				{
					zoom_slider.set_value(ZOOM_LEVELS[i]);
					embed.set_zoom(ZOOM_LEVELS[i]);
					zoom_previous = ZOOM_LEVELS[i];
					break;
				}
			}
		});

		hide.connect(() => Main.remove_window(this));
		
		load_slide(0);
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
		pane_transition.effect.set_active(Transitions.get_transition_id(slide.transition));
		if (slide.variant != "" && slide.variant != null)
		{
			pane_transition.variant.set_active(Transitions.get_variant_id(slide.transition, slide.variant));
		}
		
		embed.set_slide(slide);
	}
	
	// signal handlers
	private void show_open_dialog()
	{
		var dialog = new Gtk.FileChooserDialog("Open File",
		                                       this,
		                                       Gtk.FileChooserAction.OPEN,
		                                       null);
		dialog.run();
	}
	
	private void new_presentation()
	{
		//var window = new EditorWindow("../../../../Examples/Example.ease/");
	}
	
	// menu bar creation
	private Gtk.MenuBar create_menu_bar()
	{
		var menubar = new Gtk.MenuBar();
		
		menubar.append(create_file_menu());
		
		return menubar;
	}
	
	private Gtk.MenuItem create_file_menu()
	{
		/* TODO : use mnemonics */
		var menuItem = new Gtk.MenuItem.with_label("File");
		var menu = new Gtk.Menu();
		
		var newItem = new Gtk.MenuItem.with_label("New");
		var newMenu = new Gtk.Menu();
		var newPres = new Gtk.MenuItem.with_label("Presentation");
		newPres.activate.connect(new_presentation);
		var newTheme = new Gtk.MenuItem.with_label("Theme");
		var Quit = new Gtk.MenuItem.with_label("Quit");
		Quit.activate.connect( Gtk.main_quit );

		newMenu.append(newPres);
		newMenu.append(newTheme);
		newItem.set_submenu(newMenu);
		menu.append(newItem);
		
		var openItem = new Gtk.MenuItem.with_label("Open");
		openItem.activate.connect(show_open_dialog);
		openItem.set_accel_path("<-Document>/File/Open");
		Gtk.AccelMap.add_entry("<-Document>/File/Open",
		                       Gdk.keyval_from_name("o"),
		                       Gdk.ModifierType.CONTROL_MASK);
		menu.append(openItem);
		menu.append(Quit);
		menuItem.set_submenu(menu);
		
		return menuItem;
	}
	
	private Gtk.Alignment create_bottom_bar()
	{
		var hbox = new Gtk.HBox(false, 5);
		
		// create zoom slider
		zoom_slider = new Gtk.HScale(new Gtk.Adjustment(100, 10, 400, 10, 50, 50));
		zoom_slider.width_request = 200;
		zoom_slider.value_pos = Gtk.PositionType.RIGHT;
		zoom_slider.digits = 0;
		
		// format the slider text
		zoom_slider.format_value.connect(val => {
			return "%i%%".printf((int)val);
		});
		
		// zoom in button
		zoom_in = new Gtk.Button();
		zoom_in.add(new Gtk.Image.from_stock("gtk-zoom-in", Gtk.IconSize.MENU));
		zoom_in.relief = Gtk.ReliefStyle.NONE;
		
		// zoom out button
		zoom_out = new Gtk.Button();
		zoom_out.add(new Gtk.Image.from_stock("gtk-zoom-out", Gtk.IconSize.MENU));
		zoom_out.relief = Gtk.ReliefStyle.NONE;
		
		// put it all together
		var align = new Gtk.Alignment(0, 0.5f, 1, 0);
		align.add(zoom_out);
		hbox.pack_start(align, false, false, 0);
		
		align = new Gtk.Alignment(0, 0.5f, 1, 0);
		align.add(zoom_slider);
		hbox.pack_start(align, false, false, 0);
		
		align = new Gtk.Alignment(0, 0.5f, 1, 0);
		align.add(zoom_in);
		hbox.pack_start(align, false, false, 0);
		
		var vbox = new Gtk.VBox(false, 0);
		vbox.pack_start(new Gtk.HSeparator(), false, false, 0);
		vbox.pack_start(hbox, true, true, 2);
		
		align = new Gtk.Alignment(1, 1, 1, 1);
		align.add(vbox);
		return align;
	}
}

