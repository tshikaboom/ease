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
 * The inspector pane for changing transitions
 */
public class Ease.TransitionPane : Gtk.VBox
{
	public Gtk.ComboBox effect { get; set; }
	public Gtk.SpinButton duration { get; set; }
	public Gtk.ComboBox variant { get; set; }
	public Gtk.Alignment variant_align { get; set; }
	public Gtk.Label variant_label { get; set; }
	public Gtk.ComboBox start_transition { get; set; }
	public Gtk.SpinButton delay { get; set; }
	public GtkClutter.Embed preview;

	public TransitionPane()
	{
		homogeneous = false;
		spacing = 0;
		
		set_size_request(200, 0);
		
		// preview
		preview = new GtkClutter.Embed();
		preview.set_size_request(0, 100);
		var color = Clutter.Color();
		color.from_string("Black");
		((Clutter.Stage)(preview.get_stage())).set_color(color);
		var frame = new Gtk.Frame(null);
		frame.add(preview);
		var hbox = new Gtk.HBox(false, 0);
		hbox.pack_start(frame, true, true, 5);
		pack_start(hbox, false, false, 5);
		
		// transition selection
		var vbox = new Gtk.VBox(false, 0);
		hbox = new Gtk.HBox(false, 0);
		var align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label("Effect"));
		vbox.pack_start(align, false, false, 0);
		effect = new Gtk.ComboBox.text();
		for (var i = 0; i < Transitions.size; i++)
		{
			effect.append_text(Transitions.get_name(i));
		}
		effect.set_active(0);
		align = new Gtk.Alignment(0, 0, 1, 1);
		align.add(effect);
		vbox.pack_start(align, false, false, 0);
		hbox.pack_start(vbox, true, true, 5);
		
		// transition duration
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label("Duration"));
		vbox.pack_start(align, false, false, 0);
		duration = new Gtk.SpinButton.with_range(0, 10, 0.25);
		duration.digits = 2;
		align = new Gtk.Alignment(0, 0.5f, 1, 1);
		align.add(duration);
		vbox.pack_start(align, true, true, 0);
		hbox.pack_start(vbox, false, false, 5);
		pack_start(hbox, false, false, 5);
		
		// transition variant
		hbox = new Gtk.HBox(false, 0);
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label("Direction"));
		vbox.pack_start(align, false, false, 0);
		variant = new Gtk.ComboBox.text();
		variant_align = new Gtk.Alignment(0, 0, 1, 1);
		variant_align.add(variant);
		vbox.pack_start(variant_align, false, false, 0);
		hbox.pack_start(vbox, true, true, 5);
		pack_start(hbox, false, false, 5);
		
		// start transition
		vbox = new Gtk.VBox(false, 0);
		hbox = new Gtk.HBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label("Start Transition"));
		vbox.pack_start(align, false, false, 0);
		start_transition = new Gtk.ComboBox.text();
		start_transition.append_text("Manually");
		start_transition.append_text("Automatically");
		start_transition.set_active(0);
		align = new Gtk.Alignment(0, 0, 1, 1);
		align.add(start_transition);
		vbox.pack_start(align, false, false, 0);
		hbox.pack_start(vbox, true, true, 5);
					
		// start transition delay
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label("Delay"));
		vbox.pack_start(align, false, false, 0);
		delay = new Gtk.SpinButton.with_range(0, 10, 0.25);
		delay.digits = 2;
		align = new Gtk.Alignment(0, 0.5f, 1, 1);
		align.add(delay);
		vbox.pack_start(align, true, true, 0);
		hbox.pack_start(vbox, false, false, 5);
		pack_start(hbox, false, false, 5);
	}
}

