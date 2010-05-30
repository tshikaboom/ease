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

	// clutter view
	private ScrollableEmbed embed;

	// previews
	private Clutter.Group preview_container;
	private Clutter.Rectangle preview_background;
	private Gee.ArrayList<WelcomeActor> previews = new Gee.ArrayList<WelcomeActor>();
	private int preview_width = 100;
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
	private const int[] RESOLUTIONS_X = {800,
	                                     1024,
	                                     1280,
	                                     1280,
	                                     1920};
	private const int[] RESOLUTIONS_Y = {600,
	                                     768,
	                                     1024,
	                                     720,
	                                     1080};
	private const int RESOLUTION_COUNT = 5;
	private const int PREVIEW_PADDING = 20;
	
	private const int ANIM_TIME = 300;
	private const int ANIM_EASE = Clutter.AnimationMode.EASE_IN_OUT_SINE;
	
	private int[] ZOOM_VALUES = {100, 150, 200, 250, 400};
	
	public WelcomeWindow()
	{
		title = _("New Presentation");
		set_default_size(640, 480);
		
		// build the bottom UI
		var hbox = new Gtk.HBox(false, 5);
		resolution = new Gtk.ComboBox.text();
		resolution.append_text(_("Custom"));
		for (var i = 0; i < RESOLUTION_COUNT; i++)
		{
			resolution.append_text(_("%i by %i").printf(RESOLUTIONS_X[i], RESOLUTIONS_Y[i]));
		}
		resolution.set_active(2);
		
		var align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(resolution);
		hbox.pack_start(align, false, false, 0);
		
		x_res = new Gtk.SpinButton.with_range(RESOLUTIONS_X[0],
											  RESOLUTIONS_Y[RESOLUTION_COUNT-1],
											  1);
		x_res.set_value(1024);
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(x_res);
		hbox.pack_start(align, false, false, 0);
		
		y_res = new Gtk.SpinButton.with_range(RESOLUTIONS_Y[0],
											  RESOLUTIONS_Y[RESOLUTION_COUNT-1],
											  1);
		y_res.set_value(768);
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(y_res);
		hbox.pack_start(align, false, false, 0);
		
		new_button = new Gtk.Button.with_label(_("New Presentation"));
		new_button.sensitive = false;
		new_button.image = new Gtk.Image.from_stock("gtk-new", Gtk.IconSize.BUTTON);
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(new_button);
		hbox.pack_start(align, false, false, 0);
		
		zoom_slider = new ZoomSlider(new Gtk.Adjustment(100, 100, 400, 10,
		                                                50, 50), ZOOM_VALUES);
		hbox.pack_start(zoom_slider, false, false, 0);
		
		open_button = new Gtk.Button.from_stock("gtk-open");
		align = new Gtk.Alignment(0, 0.5f, 0, 0);
		align.add(open_button);
		hbox.pack_end(align, false, false, 0);
		
		// create the upper UI - the embed
		embed = new ScrollableEmbed(false);

		// create the preview container
		preview_container = new Clutter.Group();

		// the background for the previews
		preview_background = new Clutter.Rectangle();
		preview_background.color = {0, 0, 0, 255};
		preview_container.add_actor(preview_background);
		
		// create the previews
		for (var i = 0; i < 10; i++)
		{
			var act = new WelcomeActor(preview_width, previews);
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
		reflow_previews();
		
		// ui signals
		// changing resolution values
		x_res.value_changed.connect(() => {
			set_resolution_box((int)(x_res.get_value()),
			                   (int)(y_res.get_value()));
		});
		
		y_res.value_changed.connect(() => {
			set_resolution_box((int)(x_res.get_value()),
			                   (int)(y_res.get_value()));
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
			a.button_press_event.connect((act, event) => {
				((WelcomeActor)(act)).clicked();
				return false;
			});
		}
		
		// change the zoom of the previews when the zoom slider is moved
		zoom_slider.value_changed.connect(() => {
			preview_width = (int)zoom_slider.get_value();
			reflow_previews();
		});

		open_button.clicked.connect((sender) => OpenDialog.run());
	}
	
	private void set_resolution_box(int width, int height)
	{
		for (var i = 0; i < RESOLUTION_COUNT; i++)
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
		per_line--; // FIXME: the math is not strong in me at 2 AM
		
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
			
			if (animate_resize)
			{	
				// create new animations if the reshuffle is starting
				if (x_anims.size == i)
				{
					x_anims.add(a.animate(ANIM_EASE, ANIM_TIME, "x", x_pixels));
					y_anims.add(a.animate(ANIM_EASE, ANIM_TIME, "y", y_pixels));
				}
				
				// otherwise, replace the intial target with a new one
				else
				{
					x_anims.get(i).unbind_property("x");
					y_anims.get(i).unbind_property("y");
					
					x_anims.get(i).bind("x", x_pixels);
					y_anims.get(i).bind("y", y_pixels);
				}
			}
			else
			{
				// simply set the positions
				a.x = x_pixels;
				a.y = y_pixels;
			}

			// set the size of the preview
			a.width = preview_width;
			a.height = preview_width * preview_aspect;

			// go to the next line
			if (++x_position >= per_line)
			{
				x_position = 0;
				y_pixels += PREVIEW_PADDING + preview_width * preview_aspect;
			}
		}

		// set the size of the background
		preview_background.width = embed.width;
		preview_background.height = x_position != 0
		                          ? y_pixels + preview_width * preview_aspect +
		                            PREVIEW_PADDING
		                          : y_pixels + PREVIEW_PADDING;

		// always fill the background
		if (preview_background.height < embed.height)
		{
			preview_background.height = embed.height;
		}
	}
}
