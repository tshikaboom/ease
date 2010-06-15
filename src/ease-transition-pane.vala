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
	
	// transition preview
	private GtkClutter.Embed preview;
	private Clutter.Group preview_group;
	private Gtk.Alignment preview_align;
	private SlideActor current_slide;
	private SlideActor new_slide;
	private Clutter.Timeline preview_alarm;
	
	// constants
	private const int PREVIEW_HEIGHT = 150;
	private const uint PREVIEW_DELAY = 500;
	
	public TransitionPane()
	{
		base();
		
		// preview
		preview = new GtkClutter.Embed();
		((Clutter.Stage)(preview.get_stage())).color = {0, 0, 0, 255};
		
		preview_align = new Gtk.Alignment(0.5f, 0.5f, 1, 1);
		var frame = new Gtk.Frame(null);
		frame.shadow_type = Gtk.ShadowType.IN;
		preview_align.add(preview);
		frame.add(preview_align);
		
		pack_start(frame, false, false, 5);
		preview_group = new Clutter.Group();
		((Clutter.Stage)preview.get_stage()).add_actor(preview_group);
		
		// transition selection
		var vbox = new Gtk.VBox(false, 0);
		var hbox = new Gtk.HBox(false, 0);
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
		
		// transition time
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
				slide.automatically_advance = false;
			}
			else
			{
				delay.sensitive = true;
				slide.automatically_advance = true;
			}
		});
		
		transition_time.value_changed.connect(() => {
			slide.transition_time = transition_time.get_value();
		});
		
		delay.value_changed.connect(() => {
			slide.advance_delay = delay.get_value();
		});
		
		// automatically scale the preview to fit in the embed
		preview.get_stage().allocation_changed.connect((box, flags) => {
			preview_group.scale_x = (box.x2 - box.x1) / slide.parent.width;
			preview_group.scale_y = (box.y2 - box.y1) / slide.parent.height;
		});
		
		// automatically set the correct aspect ratio for the preview
		preview_align.size_allocate.connect((widget, allocation) => {
			if (slide == null) return;
			
			preview_align.height_request =
				(int)(allocation.width / slide.parent.aspect);
		});
	}
	
	private void animate_preview()
	{
		current_slide.reset(preview_group);
		new_slide.reset(preview_group);
		new_slide.opacity = 0;
		
		preview_alarm = new Clutter.Timeline(PREVIEW_DELAY);
		preview_alarm.completed.connect(() => {
			animate_preview_start();
		});
		preview_alarm.start();
	}
	
	private void animate_preview_start()
	{
		new_slide.opacity = 255;
		
		current_slide.transition(new_slide, preview_group);
		
		preview_alarm = new Clutter.Timeline(slide.transition_msecs);
		preview_alarm.completed.connect(() => {
			animate_preview_delay();
		});
		preview_alarm.start();
	}
	
	private void animate_preview_delay()
	{
		preview_alarm = new Clutter.Timeline(PREVIEW_DELAY);
		preview_alarm.completed.connect(() => {
			animate_preview();
		});
		preview_alarm.start();
	}
	
	protected override void slide_updated()
	{
		// set transition time box
		transition_time.set_value(slide.transition_time);
		
		// set effect and variant combo boxes
		var index = Transitions.get_index(slide.transition);
		effect.set_active(index);
		
		// set the automatic advance boxes
		start_transition.set_active(slide.automatically_advance ? 1 : 0);
		delay.set_value(slide.advance_delay);
		delay.sensitive = slide.automatically_advance;
		
		// size the preview box
		Gtk.Allocation alloc = Gtk.Allocation();
		preview_align.get_allocation(out alloc);
		preview_align.height_request = (int)(alloc.width / slide.parent.aspect);
		
		// remove the old preview slide actors
		preview_group.remove_all();
		
		// add new slide previews
		current_slide = new SlideActor.from_slide(slide.parent, slide, true,
		                                          ActorContext.PRESENTATION);
		
		new_slide = slide.parent.has_next_slide(slide) ?
		            new SlideActor.from_slide(slide.parent, slide.next, true,
		                                      ActorContext.PRESENTATION) :
		            new SlideActor.blank(slide.parent, { 0, 0, 0, 255 });
		
		preview_group.add_actor(current_slide);
		preview_group.add_actor(new_slide);
		
		// start the preview animation
		if (preview_alarm != null)
		{
			preview_alarm.stop();
		}
		animate_preview();
	}
}

