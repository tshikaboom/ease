namespace Ease
{
	public class EditorWindow : Gtk.Window
	{
		// interface elements
		public EditorEmbed embed { get; set; }
		public MainToolbar main_toolbar { get; set; }
		public Gtk.HBox inspector { get; set; }
		public Gtk.ScrolledWindow slides { get; set; }
		public Gtk.VBox slides_box { get; set; }
		public TransitionPane pane_transition { get; set; }
		public SlidePane pane_slide { get; set; }
		
		public Document document { get; set; }
		public Slide slide { get; set; }
		
		// interface variables
		public bool inspector_shown { get; set; }
		public bool slides_shown { get; set; }
		
		public EditorWindow(string filename)
		{
			this.title = "";
			this.set_default_size(1024, 768);
			
			document = new Document.from_file(filename);
			
			var vbox = new Gtk.VBox(false, 0);
			vbox.pack_start(create_menu_bar(), false, false, 0);
			main_toolbar = new MainToolbar();
			vbox.pack_start(main_toolbar, false, false, 0);
			//vbox.pack_start(new Gtk.HSeparator(), false, false, 0);
			
			embed = new EditorEmbed(document);
			var hbox = new Gtk.HBox(false, 0);
			
			// slide display
			slides = new Gtk.ScrolledWindow(null, null);
			slides.set_size_request(150, 0);
			slides.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			slides.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			slides_box = new Gtk.VBox(true, 1);
			for (int i = 0; i < document.slides.size; i++)
			{
				var button = new SlideButton(i, document.slides.get(i));
				button.clicked.connect(() => {
					for (unowned GLib.List* itr = slides_box.get_children(); itr != null; itr = itr->next)
					{
						((SlideButton*)(itr->data))->set_relief(Gtk.ReliefStyle.NONE);
					}
					button.relief = Gtk.ReliefStyle.NORMAL;
					load_slide(button.slide_id);
				});
				slides_box.pack_start(button, false, false, 0);
			}
			var align = new Gtk.Alignment(0, 0, 1, 0);
			align.add(slides_box);
			slides.add_with_viewport(align);
			
			// the inspector
			inspector = new Gtk.HBox(false, 0);
			//inspector.pack_start(new Gtk.VSeparator(), false, false, 0);
			var notebook = new Gtk.Notebook();
			notebook.scrollable = true;
			pane_transition = new TransitionPane();
			pane_slide = new SlidePane();
			notebook.append_page(pane_slide, new Gtk.Image.from_stock("gtk-page-setup", Gtk.IconSize.SMALL_TOOLBAR));
			notebook.append_page(pane_transition, new Gtk.Image.from_stock("gtk-media-forward", Gtk.IconSize.SMALL_TOOLBAR));
			inspector.pack_start(notebook, false, false, 0);
			
			var embed_vbox = new Gtk.VBox(false, 0);
			//embed_vbox.pack_start(new Gtk.HSeparator(), false, false, 0);
			embed_vbox.pack_start(embed, true, true, 0);
			hbox.pack_start(slides, false, false, 0);
			hbox.pack_start(embed_vbox, true, true, 0);
			hbox.pack_start(inspector, false, false, 0);
			vbox.pack_start(hbox, true, true, 0);
			
			this.add(vbox);
			
			this.show_all();
			embed.show();
			inspector.hide();
			inspector_shown = false;
			slides_shown = true;
			
			// ui signals
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
			pane_transition.effect.changed.connect(() => {
				var variants = Transitions.get_variants(pane_transition.effect.active);
				pane_transition.variant_align.remove(pane_transition.variant);
				pane_transition.variant = new Gtk.ComboBox.text();
				pane_transition.variant_align.add(pane_transition.variant);
				pane_transition.variant.show();
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
			main_toolbar.play.clicked.connect(() => {
				var player = new Player(document);
				Clutter.main();
			});
			
			load_slide(0);
		}
		
		private void load_slide(int index)
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
			var menuItem = new Gtk.MenuItem.with_label("File");
			var menu = new Gtk.Menu();
			
			var newItem = new Gtk.MenuItem.with_label("New");
			var newMenu = new Gtk.Menu();
			var newPres = new Gtk.MenuItem.with_label("Presentation");
			newPres.activate.connect(new_presentation);
			var newTheme = new Gtk.MenuItem.with_label("Theme");
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
			
			menuItem.set_submenu(menu);
			
			return menuItem;
		}
	}
}