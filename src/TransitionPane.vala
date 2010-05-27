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
	public Gtk.SpinButton transition_time { get; set; }
	public Gtk.ComboBox variant { get; set; }
	public Gtk.Alignment variant_align { get; set; }
	public Gtk.Label variant_label { get; set; }
	public Gtk.ComboBox start_transition { get; set; }
	public Gtk.SpinButton delay { get; set; }
	public GtkClutter.Embed preview;
	
	
	private Slide slide_priv;
	public Slide slide
	{
		get { return slide_priv; }
		set {
			slide_priv = value;
			transition_time.set_value(value.transition_time);
		}
	}

	public TransitionPane()
	{
		homogeneous = false;
		spacing = 0;
		
		set_size_request(200, 0);
		
		// preview
		preview = new GtkClutter.Embed();
		preview.set_size_request(0, 100);
		((Clutter.Stage)(preview.get_stage())).color = {0, 0, 0, 255};
		var frame = new Gtk.Frame(null);
		frame.add(preview);
		var hbox = new Gtk.HBox(false, 0);
		hbox.pack_start(frame, true, true, 5);
		pack_start(hbox, false, false, 5);
		
		// transition selection
		var vbox = new Gtk.VBox(false, 0);
		hbox = new Gtk.HBox(false, 0);
		var align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label(_("Effect")));
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
		
		// transition transition_time
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label(_("Duration")));
		vbox.pack_start(align, false, false, 0);
		transition_time = new Gtk.SpinButton.with_range(0, 10, 0.25);
		transition_time.digits = 2;
		align = new Gtk.Alignment(0, 0.5f, 1, 1);
		align.add(transition_time);
		vbox.pack_start(align, true, true, 0);
		hbox.pack_start(vbox, false, false, 5);
		pack_start(hbox, false, false, 5);
		
		transition_time.value_changed.connect(() => {
			slide.transition_time = transition_time.get_value();
		});
		
		// transition variant
		hbox = new Gtk.HBox(false, 0);
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label(_("Direction")));
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
		align.add(new Gtk.Label(_("Start Transition")));
		vbox.pack_start(align, false, false, 0);
		start_transition = new Gtk.ComboBox.text();
		start_transition.append_text(_("Manually"));
		start_transition.append_text(_("Automatically"));
		start_transition.set_active(0);
		align = new Gtk.Alignment(0, 0, 1, 1);
		align.add(start_transition);
		vbox.pack_start(align, false, false, 0);
		hbox.pack_start(vbox, true, true, 5);
					
		// start transition delay
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label(_("Delay")));
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

