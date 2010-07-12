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
 * The window shown when Ease starts
 *
 * The WelcomeWindow contains a {@link ScrollableEmbed} with
 * {@link WelcomeActor}s for each {@link Theme} installed. From this
 * window, the user can either create a new {@link Document} or open
 * an existing one.
 */
public class Ease.WelcomeWindow : Gtk.Window
{
	// main buttons
	private Gtk.Button new_button;
	private Gtk.Button open_button;
	private Gtk.ComboBox resolution;
	private Gtk.SpinButton x_res;
	private Gtk.SpinButton y_res;
	
	// themes
	private Gee.ArrayList<Theme> themes = new Gee.ArrayList<Theme>();
	private Theme selected_theme;

	// clutter view
	private ScrollableEmbed embed;

	// previews
	private Clutter.Group preview_container;
	private Clutter.Rectangle preview_background;
	private Gee.ArrayList<WelcomeActor> previews = new Gee.ArrayList<WelcomeActor>();
	private int preview_width;
	private float preview_aspect;
	
	// preview reshuffle animation
	private int preview_row_count = -1;
	private bool animate_resize = false;
	private Clutter.Timeline animate_alarm;
	private Gee.ArrayList<Clutter.Animation> x_anims;
	private Gee.ArrayList<Clutter.Animation> y_anims;

	// zoom widgets
	private ZoomSlider zoom_slider;
	
	// constants
	private const int[] RESOLUTIONS_X = {640,
	                                     800,
	                                     1024,
	                                     1280,
	                                     1280,
	                                     1920};
	private const int[] RESOLUTIONS_Y = {480,
	                                     600,
	                                     768,
	                                     1024,
	                                     720,
	                                     1080};
	
	private const int PREVIEW_PADDING = 20;
	private const int PREVIEW_VERT_PADDING = 35;
	
	private const int DEFAULT_ACTIVE = 2;
	
	private const int ANIM_TIME = 300;
	private const int ANIM_EASE = Clutter.AnimationMode.EASE_IN_OUT_SINE;
	
	private int[] ZOOM_VALUES = {100, 150, 200, 250, 400};
	
	private const string PREVIEW_ID = "Standard";
	
	public WelcomeWindow()
	{
		assert(RESOLUTIONS_X.length == RESOLUTIONS_Y.length);
	
		this.title = _("Pick a theme and start editing");
		this.set_default_size(640, 480);
		
		var builder = new Gtk.Builder ();
		try {
			builder.add_from_file ("data/ui/welcome-window.ui");
			//FIXME : compute path
		} catch (Error e) {
			error ("Unable to load UI : %s", e.message);
		}

		var vbox = builder.get_object ("vbox1") as Gtk.VBox;
		var hbox = builder.get_object ("hbox1") as Gtk.HBox;

		zoom_slider = new ZoomSlider(new Gtk.Adjustment(100, 100, 400, 10,
		                                                50, 50), ZOOM_VALUES);
		hbox.pack_start (zoom_slider, false, false);
		hbox.reorder_child (zoom_slider, 4);

		this.add (vbox);

		this.show_all ();
/*		// build the bottom UI
		var hbox = new Gtk.HBox(false, 5);
		resolution = new Gtk.ComboBox.text();
		resolution.append_text(_("Custom"));
		for (var i = 0; i < RESOLUTIONS_X.length; i++)
		{
			resolution.append_text(_("%i by %i").printf(RESOLUTIONS_X[i],
			                                            RESOLUTIONS_Y[i]));
		}
		
		var align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(resolution);
		hbox.pack_start(align, false, false, 0);
		
		var resolution_count = RESOLUTIONS_X.length;
		x_res = new Gtk.SpinButton.with_range(RESOLUTIONS_X[0],
											  RESOLUTIONS_X[resolution_count-1],
											  1);
											  
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(x_res);
		hbox.pack_start(align, false, false, 0);
		
		y_res = new Gtk.SpinButton.with_range(RESOLUTIONS_Y[0],
											  RESOLUTIONS_Y[resolution_count-1],
											  1);
		
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(y_res);
		hbox.pack_start(align, false, false, 0);
		
		new_button = new Gtk.Button.with_label(_("New Presentation"));
		new_button.sensitive = false;
		new_button.image = new Gtk.Image.from_stock("gtk-new",
		                                            Gtk.IconSize.BUTTON);
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(new_button);
		hbox.pack_start(align, false, false, 0);
		
		hbox.pack_start(zoom_slider, false, false, 0);
		
		open_button = new Gtk.Button.from_stock("gtk-open");
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(open_button);
		hbox.pack_end(align, false, false, 0);
		
		// create the upper UI - the embed
		embed = new ScrollableEmbed(false, false);
		embed.get_stage().use_fog = false;

		// create the preview container
		preview_container = new Clutter.Group();

		// the background for the previews
		preview_background = new Clutter.Rectangle();
		preview_background.color = {0, 0, 0, 255};
		preview_container.add_actor(preview_background);
		
		// load themes
		try
		{
			string[] data_dirs = Environment.get_system_data_dirs();
			foreach (string dir in data_dirs)
			{
				var filename = Path.build_filename(dir,
				                                   Temp.TEMP_DIR,
				                                   Temp.THEME_DIR);
				var file = File.new_for_path(filename);
				
				if (file.query_exists(null))
				{
					var directory = GLib.Dir.open(filename, 0);
					
					string name = directory.read_name();
					while (name != null)
					{
						var path = Path.build_filename(filename, name);
						themes.add(JSONParser.theme(path));
						name = directory.read_name();
					}
				}
			}
		}
		catch (Error e) { error_dialog("Error Loading Themes", e.message); }
		
		// create the previews
		foreach (var theme in themes)
		{
			var master = theme.slide_by_title(PREVIEW_ID);
			if (master == null) continue;
			
			var act = new WelcomeActor(theme, previews, master);
			previews.add(act);
			preview_container.add_actor(act);
			
			act.selected.connect(() => {
				new_button.sensitive = true;
			});
		}
		embed.contents.add_actor(preview_container);
		embed.contents.show_all();
		
		// put it all together
		var vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 1, 1, 0);
		align.add(hbox);
		align.set_padding(5, 5, 5, 5);
		vbox.pack_end(align, false, false, 0);
		vbox.pack_end(new Gtk.HSeparator(), false, false, 0);
		vbox.pack_start(embed, true, true, 0);
		
		add(vbox);
		show_all();
		
		// ui signals
		new_button.clicked.connect(new_document);
		
		// changing resolution values
		x_res.value_changed.connect(() => {
			set_resolution_box((int)(x_res.get_value()),
			                   (int)(y_res.get_value()));
			foreach (var p in previews)
			{
				p.set_slide_size((int)x_res.get_value(),
				                 (int)y_res.get_value());
			}
		});
		
		y_res.value_changed.connect(() => {
			set_resolution_box((int)(x_res.get_value()),
			                   (int)(y_res.get_value()));
			foreach (var p in previews)
			{
				p.set_slide_size((int)x_res.get_value(),
				                 (int)y_res.get_value());
			}
		});
		
		resolution.changed.connect(() => {
			var val = resolution.get_active();
			if (val > 0)
			{
				x_res.set_value(RESOLUTIONS_X[val - 1]);
				y_res.set_value(RESOLUTIONS_Y[val - 1]);
			}
			reflow_previews();
		});
		
		// reflow the stage
		embed.size_allocate.connect(() => {
			reflow_previews();
		});
		
		// click on previews
		foreach (var a in previews)
		{
			a.button_press_event.connect((act, event) =>
                {
                    if (event.click_count == 2) {
						new_document();
					}
					(act as WelcomeActor).clicked();
					selected_theme = (act as WelcomeActor).theme;
					return false;
				});
		}
		
		// change the zoom of the previews when the zoom slider is moved
		zoom_slider.value_changed.connect(() => {
			preview_width = (int)zoom_slider.get_value();
			reflow_previews();
		});

		open_button.clicked.connect((sender) => OpenDialog.run());
		
		resolution.set_active(DEFAULT_ACTIVE + 1);
		
		preview_width = (int)zoom_slider.get_value();
		
		// reflow previews without animation
		preview_row_count = -1;
		reflow_previews();
		}*/
	}
	
	private void new_document()
	{
		try
		{
			// create a new Document
			var document = new Document.from_theme(selected_theme,
												   (int)x_res.get_value(),
												   (int)y_res.get_value());

			// create an EditorWindow for the new Document
			var editor = new EditorWindow(document);

			Main.add_window(editor);
			Main.remove_welcome();
		}
		catch (Error e)
		{
			error_dialog(_("Error creating new document"), e.message);
		}
	}
	
	private void set_resolution_box(int width, int height)
	{
		for (var i = 0; i < RESOLUTIONS_X.length; i++)
		{
			if (width == RESOLUTIONS_X[i] && height == RESOLUTIONS_Y[i])
			{
				resolution.set_active(i + 1);
				return;
			}
		}
		resolution.set_active(0);
		reflow_previews();
	}
	
	private void reflow_previews()
	{
		// calculate the preview aspect ratio
		preview_aspect = (float)(y_res.get_value() / x_res.get_value());
		
		// calculate the number of previews per line
		var per_line = 2;
		for (; per_line * (preview_width + PREVIEW_PADDING) +
		       PREVIEW_PADDING < embed.width;
		     per_line++);
		per_line--;
		
		// don't animate when the window first opens
		if (preview_row_count == -1)
		{
			preview_row_count = per_line;
		}
		
		// animate if the previews need to be shuffled
		if (preview_row_count != per_line)
		{
			preview_row_count = per_line;
			animate_resize = true;
			
			if (animate_alarm != null)
				animate_alarm.stop();
				
			// create animation arrays
			x_anims = new Gee.ArrayList<Clutter.Animation>();
			y_anims = new Gee.ArrayList<Clutter.Animation>();
			
			animate_alarm = new Clutter.Timeline(ANIM_TIME);
			animate_alarm.start();
			animate_alarm.completed.connect(() => {
				animate_resize = false;
				x_anims = null;
				y_anims = null;
			});
		}

		// find the initial x position of previews
		var x_origin = embed.width / 2 -
		    (preview_width * per_line + PREVIEW_PADDING * (per_line - 1)) / 2;

		// the y position in pixels
		float y_pixels = PREVIEW_PADDING;

		// the x position in previews
		int x_position = 0;

		// place the previews
		for (var i = 0; i < previews.size; i++)
		{
			// set the position of the preview
			WelcomeActor a = previews.get(i);
			
			if (a == null)
			{
				continue;
			}
			
			// the target x position of the preview
			float x_pixels = x_origin + x_position *
			                  (PREVIEW_PADDING + preview_width);
			
			float x_round = roundd(x_pixels);
			float y_round = roundd(y_pixels);
			
			if (animate_resize)
			{	
				// create new animations if the reshuffle is starting
				if (x_anims.size == i)
				{
					x_anims.add(a.animate(ANIM_EASE, ANIM_TIME, "x", x_round));
					y_anims.add(a.animate(ANIM_EASE, ANIM_TIME, "y", y_round));
				}
				
				// otherwise, replace the intial target with a new one
				else
				{
					x_anims.get(i).unbind_property("x");
					y_anims.get(i).unbind_property("y");
					
					x_anims.get(i).bind("x", x_round);
					y_anims.get(i).bind("y", y_round);
				}
			}
			else
			{
				// simply set the positions
				a.x = x_pixels;
				a.y = y_pixels;
			}

			// set the size of the preview
			a.set_dims(preview_width, preview_width * preview_aspect);

			// go to the next line
			if (++x_position >= per_line)
			{
				x_position = 0;
				y_pixels += PREVIEW_VERT_PADDING + preview_width * preview_aspect;
			}
		}

		// set the size of the background
		preview_background.width = embed.width;
		preview_background.height = x_position != 0
		                          ? y_pixels + preview_width * preview_aspect +
		                            PREVIEW_VERT_PADDING
		                          : y_pixels + PREVIEW_VERT_PADDING;

		// always fill the background
		if (preview_background.height < embed.height)
		{
			preview_background.height = embed.height;
		}
	}
}
