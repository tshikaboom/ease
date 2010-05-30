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
public class Ease.TransitionPane : InspectorPane
{
	public Gtk.ComboBox effect;
	private Gtk.SpinButton transition_time;
	public Gtk.ComboBox variant;
	private Gtk.Alignment variant_align;
	private Gtk.ComboBox start_transition;
	private Gtk.SpinButton delay;
	private GtkClutter.Embed preview;

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
		
		
		// signal handlers
		effect.changed.connect(() => {			
			// create a new ComboBox
			variant_align.remove(variant);
			variant = new Gtk.ComboBox.text();
			variant_align.add(variant);
			variant.show();
			
			// get the variants for the new transition
			var variants = Transitions.variants_for_index(effect.active);
			
			// add the transition's variants
			for (var i = 0; i < variants.length; i++)
			{
				variant.append_text(Transitions.get_variant_name(variants[i]));
			}
			
			// if the slide has variants, make the appropriate one active
			for (int i = 0; i < variants.length; i++)
			{
				if (variants[i] == slide.variant)
				{
					variant.set_active(i);
					break;
				}
			}
			
			// set the transition
			slide.transition = Transitions.transition_for_index(effect.active);
			
			// allow the user to change the variant
			variant.changed.connect(() => {
				var v = Transitions.variants_for_transition(slide.transition);
				slide.variant = v[variant.active];
			});
		});
		
		start_transition.changed.connect(() => {
			if (start_transition.active == 0)
			{
				delay.sensitive = false;
			}
			else
			{
				delay.sensitive = true;
			}
		});
	}
	
	protected override void slide_updated()
	{
		// set transition time box
		transition_time.set_value(slide.transition_time);
		
		// set effect and variant combo boxes
		var index = Transitions.get_index(slide.transition);
		effect.set_active(index);
	}
}

