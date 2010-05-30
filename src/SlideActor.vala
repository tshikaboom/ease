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
 * A Clutter actor for a Slide
 *
 * SlideActor is a subclass of Clutter.Group. It is used in both the
 * editor and player, as well as assorted other preview screens.
 */
public class Ease.SlideActor : Clutter.Group
{
	// the represented slide
	public Slide slide;

	// the slide's background
	public Clutter.Actor background;

	// the slide's contents
	//public Gee.ArrayList<Actor> contents_list;

	// the group of the slide's contents
	public Clutter.Group contents;

	// the context of the actor (presentation, etc.)
	public ActorContext context;

	// timelines
	public Clutter.Timeline animation_time { get; set; }
	private Clutter.Alpha animation_alpha { get; set; }
	private Clutter.Timeline time1;
	private Clutter.Timeline time2;
	private Clutter.Alpha alpha1;
	private Clutter.Alpha alpha2;

	// constants
	public const int EASE_SLIDE = Clutter.AnimationMode.EASE_IN_OUT_SINE;

	public const int EASE_DROP = Clutter.AnimationMode.EASE_OUT_BOUNCE;

	public const int EASE_PIVOT =	Clutter.AnimationMode.EASE_OUT_SINE;

	public const float FLIP_DEPTH = -400;
	public const float ZOOM_OUT_SCALE = 0.75f;
	private const float OPEN_DEPTH = -3000;
	private const float OPEN_MOVE = 0.15f;
	private const float OPEN_TIME = 0.8f;
	private const int SLAT_COUNT = 8;

	public SlideActor.from_slide(Document document, Slide s, bool clip,
	                              ActorContext ctx)
	{
		slide = s;
		context = ctx;

		// clip the actor's bounds
		if (clip)
		{
			set_clip(0, 0, document.width, document.height);
		}

		// set the background
		set_background();

		contents = new Clutter.Group();

		foreach (var e in slide.elements)
		{
			// load the proper type of actor
			switch (e.data.get("element_type"))
			{
				case "image":
					contents.add_actor(new ImageActor(e, context));
					break;
				case "text":
					contents.add_actor(new TextActor(e, context));
					break;
				case "video":
					contents.add_actor(new VideoActor(e, context));
					break;
			}
		}

		add_actor(contents);
	}

	public void relayout()
	{
		set_background();

		for (unowned List<Clutter.Actor>* itr = contents.get_children();
		     itr != null;
		     itr = itr->next)
		{
			((Actor)(itr->data)).reposition();
		}
	}

	/**
	 * Builds the background actor for this SlideActor.
	 */
	private void set_background()
	{
		if (background != null)
		{
			if (background.get_parent() == this)
			{
				remove_actor(background);
			}
		}

		if (slide.background_image != null)
		{
			try
			{
				background = new Clutter.Texture.from_file(slide.parent.path +
				                                    slide.background_image);
			}
			catch (GLib.Error e)
			{
				stdout.printf(_("Error loading background: %s"), e.message);
			}
		}
		else // the background is a solid color
		{
			background = new Clutter.Rectangle();
			((Clutter.Rectangle)background).color = slide.background_color;
		}
		background.width = slide.parent.width;
		background.height = slide.parent.height;

		add_actor(background);
		lower_child(background, null);
	}

	// stack the actor, removing children from container if needed
	public void stack(Clutter.Actor container)
	{
		if (background.get_parent() != this)
		{
			background.reparent(this);
		}
		if (contents.get_parent() != this)
		{
			contents.reparent(this);
		}
	}

	// unstack the actor, layering it with another actor
	public void unstack(SlideActor other, Clutter.Actor container)
	{
		if (other.background.get_parent() != container)
		{
			other.background.reparent(container);
		}
		if (background.get_parent() != container)
		{
			background.reparent(container);
		}
		if (contents.get_parent() != container)
		{
			contents.reparent(container);
		}
		if (other.contents.get_parent() != container)
		{
			other.contents.reparent(container);
		}
	}

	private void prepare_slide_transition(SlideActor new_slide,
	                                      Clutter.Group stack_container)
	{
		new_slide.stack(stack_container);
		stack(stack_container);
	}

	private void prepare_stack_transition(bool current_on_top,
	                                      SlideActor new_slide,
	                                      Clutter.Group stack_container)
	{
		unstack(new_slide, stack_container);
	}

	public void transition(SlideActor new_slide,
	                       Clutter.Group stack_container)
	{
		uint length = (uint)max(1, slide.transition_time * 1000);

		animation_time = new Clutter.Timeline(length);

		switch (slide.transition)
		{
			case TransitionType.SLIDE:
				slide_transition(new_slide, stack_container, length);
				break;

			case TransitionType.DROP:
				drop_transition(new_slide, stack_container, length);
				break;

			case TransitionType.PIVOT:
				pivot_transition(new_slide, stack_container, length);
				break;

			case TransitionType.OPEN_DOOR:
				open_door_transition(new_slide, stack_container, length);
				break;

			case TransitionType.REVEAL:
				reveal_transition(new_slide, stack_container, length);
				break;

			case TransitionType.SLATS:
				slats_transition(new_slide, stack_container, length);
				break;

			case TransitionType.FLIP:
				flip_transition(new_slide, stack_container, length);
				break;

			case TransitionType.REVOLVING_DOOR:
				revolving_door_transition(new_slide, stack_container, length);
				break;

			case TransitionType.FALL:
				fall_transition(new_slide, stack_container, length);
				break;

			case TransitionType.SPIN_CONTENTS:
				spin_contents_transition(new_slide, stack_container, length);
				break;

			case TransitionType.SWING_CONTENTS:
				swing_contents_transition(new_slide, stack_container, length);
				break;

			case TransitionType.ZOOM:
				zoom_transition(new_slide, stack_container, length);
				break;

			case TransitionType.SLIDE_CONTENTS:
				slide_contents_transition(new_slide, stack_container, length);
				break;

			case TransitionType.SPRING_CONTENTS:
				spring_contents_transition(new_slide, stack_container, length);
				break;

			case TransitionType.ZOOM_CONTENTS:
				zoom_contents_transition(new_slide, stack_container, length);
				break;

			case TransitionType.PANEL:
				panel_transition(new_slide, stack_container, length);
				break;
				
			default: // FADE, or something undefined
				fade_transition(new_slide, stack_container, length);
				break;
		}
		
		animation_time.start();
	}

	private void fade_transition(SlideActor new_slide,
	                             Clutter.Group stack_container, uint length)
	{
		prepare_slide_transition(new_slide, stack_container);
		new_slide.opacity = 0;
		new_slide.animate(Clutter.AnimationMode.LINEAR,
		                  length, "opacity", 255);
	}

	private void slide_transition(SlideActor new_slide,
	                              Clutter.Group stack_container, uint length)
	{
		switch (slide.variant)
		{
			case TransitionVariant.UP:
				new_slide.y = slide.parent.height;
				new_slide.animate(EASE_SLIDE, length, "y", 0);
				animate(EASE_SLIDE, length, "y", -new_slide.y);
				break;
			
			case TransitionVariant.DOWN:
				new_slide.y = -slide.parent.height;
				new_slide.animate(EASE_SLIDE, length, "y", 0);
				animate(EASE_SLIDE, length, "y", -new_slide.y);
				break;
			
			case TransitionVariant.LEFT:
				new_slide.x = slide.parent.width;
				new_slide.animate(EASE_SLIDE, length, "x", 0);
				animate(EASE_SLIDE, length, "x", -new_slide.x);
				break;
			
			case TransitionVariant.RIGHT:
				new_slide.x = -slide.parent.width;
				new_slide.animate(EASE_SLIDE, length, "x", 0);
				animate(EASE_SLIDE, length, "x", -new_slide.x);
				break;
		}
	}

	private void drop_transition(SlideActor new_slide,
	                             Clutter.Group stack_container, uint length)
	{
		new_slide.y = -slide.parent.height;
		new_slide.animate(EASE_DROP, length, "y", 0);
	}

	private void pivot_transition(SlideActor new_slide,
	                              Clutter.Group stack_container, uint length)
	{
		float xpos = 0, ypos = 0, angle = 90;
		switch (slide.variant)
		{
			case TransitionVariant.TOP_RIGHT:
				xpos = slide.parent.width;
				angle = -90;
				break;
			case TransitionVariant.BOTTOM_LEFT:
				ypos = slide.parent.height;
				angle = -90;
				break;
			case TransitionVariant.BOTTOM_RIGHT:
				xpos = slide.parent.width;
				ypos = slide.parent.height;
				break;
		}
		
		// set the new slide's intial angle
		new_slide.set_rotation(Clutter.RotateAxis.Z_AXIS,
		                       angle, xpos, ypos, 0);
		animation_alpha = new Clutter.Alpha.full(animation_time,
		                                         EASE_PIVOT);
		
		// rotate the new slide in
		animation_time.new_frame.connect((m) => {
			new_slide.set_rotation(Clutter.RotateAxis.Z_AXIS,
			                       angle * (1 - animation_alpha.alpha),
			                       xpos, ypos, 0);
		});
	}

	private void flip_transition(SlideActor new_slide,
	                             Clutter.Group stack_container, uint length)
	{
		// hide the new slide
		new_slide.opacity = 0;
		
		// timing
		time1 = new Clutter.Timeline(length / 2);
		time2 = new Clutter.Timeline(length / 2);
		alpha1 = new Clutter.Alpha.full(time1,
		                                Clutter.AnimationMode.EASE_IN_SINE);
		alpha2 = new Clutter.Alpha.full(time2,
		                                Clutter.AnimationMode.EASE_OUT_SINE);
		
		// axis to flip on
		Clutter.RotateAxis axis;
		
		// multiplier for angle
		float positive;
		
		// rotation points
		float x_point = 0, y_point = 0;
		
		switch (slide.variant)
		{
			case TransitionVariant.BOTTOM_TO_TOP:
				axis = Clutter.RotateAxis.X_AXIS;
				positive = 1;
				y_point = slide.parent.height / 2;
				break;

			case TransitionVariant.TOP_TO_BOTTOM:
				axis = Clutter.RotateAxis.X_AXIS;
				positive = -1;
				break;

			case TransitionVariant.LEFT_TO_RIGHT:
				axis = Clutter.RotateAxis.Y_AXIS;
				positive = 1;
				x_point = slide.parent.width / 2;
				break;

			default: // RIGHT_TO_LEFT
				axis = Clutter.RotateAxis.Y_AXIS;
				positive = -1;
				x_point = slide.parent.width / 2;
				break;
		}
		
		// animate the first half of the transition
		time1.new_frame.connect((m) => {
			// rotate the slide
			set_rotation(axis, positive * 90 * alpha1.alpha,
			             x_point, y_point, 0);
			
			// zoom the slide in
			depth = (float)(FLIP_DEPTH * alpha1.alpha);
		});

		// animate the second half of the transition
		time2.new_frame.connect((m) => {
			// rotate the slide
			new_slide.set_rotation(axis, positive * -90 * (1 - alpha2.alpha),
			                       x_point, y_point, 0);
			
			// zoom the slide in
			new_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.alpha);
			
			// make the new slide visible
			new_slide.opacity = 255;
		});
		
		time1.completed.connect(() => {
			// hide the current slide
			opacity = 0;
			
			// place the new slide
			new_slide.depth = FLIP_DEPTH;
			
			// start the second half
			time2.start();
		});
		
		// start the transition
		time1.start();
	}

	private void revolving_door_transition(SlideActor new_slide,
	                                       Clutter.Group stack_container,
	                                       uint length)
	{
		// set the current slide to slightly above the new slide
		depth = 1;

		animation_alpha = new Clutter.Alpha.full(animation_time, EASE_SLIDE);
		
		// the axis of rotation
		Clutter.RotateAxis axis;
		
		// angle multiplier, -1 or 1
		float positive;
		
		// angle rotation points
		float x_point = 0, y_point = 0;
		
		switch (slide.variant)
		{
			case TransitionVariant.LEFT:
				axis = Clutter.RotateAxis.Y_AXIS;
				positive = 1;
				break;
			
			case TransitionVariant.RIGHT:
				axis = Clutter.RotateAxis.Y_AXIS;
				positive = -1;
				x_point = slide.parent.width;
				break;
			
			case TransitionVariant.TOP:
				axis = Clutter.RotateAxis.X_AXIS;
				positive = -1;
				break;
			
			default: // BOTTOM
				axis = Clutter.RotateAxis.X_AXIS;
				positive = 1;
				y_point = slide.parent.height;
				break;
		}
		
		// set the new slide's initial rotation
		new_slide.set_rotation(axis, 90 * positive, x_point, y_point, 0);
		
		animation_time.new_frame.connect((m) => {
			// rotate the new slide in
			new_slide.set_rotation(axis,
			                       positive * 90 * (1 - animation_alpha.alpha),
			                       x_point, y_point, 0);
			
			// rotate the old slide forwards
			set_rotation(axis,
			             positive * -110 * animation_alpha.alpha,
			             x_point, y_point, 0);
		});
	}

	private void reveal_transition(SlideActor new_slide,
	                               Clutter.Group stack_container, uint length)
	{
		// TODO: make this transition not a total hack
		((Clutter.Container)get_parent()).raise_child(this, new_slide);

		switch (slide.variant)
		{
			case TransitionVariant.TOP:
				new_slide.y = slide.parent.height;
				animate(EASE_SLIDE, length, "y", -new_slide.y);
				new_slide.y = 0;
				break;
			case TransitionVariant.BOTTOM:
				new_slide.y = -slide.parent.height;
				animate(EASE_SLIDE, length, "y", -new_slide.y);
				new_slide.y = 0;
				break;
			case TransitionVariant.LEFT:
				new_slide.x = slide.parent.width;
				this.animate(EASE_SLIDE, length, "x", -new_slide.x);
				new_slide.x = 0;
				break;
			case TransitionVariant.RIGHT:
				new_slide.x = -slide.parent.width;
				animate(EASE_SLIDE, length, "x", -new_slide.x);
				new_slide.x = 0;
				break;
		}
	}

	private void fall_transition(SlideActor new_slide,
	                             Clutter.Group stack_container, uint length)
	{
		depth = 1;

		animation_alpha = new Clutter.Alpha.full(animation_time,
		                                   Clutter.AnimationMode.EASE_IN_QUART);
		animation_time.new_frame.connect((m) => {
			set_rotation(Clutter.RotateAxis.X_AXIS,
			             -90 * animation_alpha.alpha,
			             0, slide.parent.height, 0);
		});
	}

	private void slats_transition(SlideActor new_slide,
	                              Clutter.Group stack_container, uint length)
	{
		// hide the real SlideActors
		reparent(stack_container);
		new_slide.reparent(stack_container);
		x = slide.parent.width;
		new_slide.x = slide.parent.width;

		// make arrays for the slats
		var this_slats = new Clutter.Clone[SLAT_COUNT];
		var new_slats = new Clutter.Clone[SLAT_COUNT];
		var groups = new Clutter.Group[SLAT_COUNT];

		// calculate the width of each slat
		float width = (float)slide.parent.width / SLAT_COUNT;

		// make the slats
		for (int i = 0; i < SLAT_COUNT; i++)
		{
			// create groups
			groups[i] = new Clutter.Group();
			stack_container.add_actor(groups[i]);

			// create clones
			this_slats[i] = new Clutter.Clone(this);
			groups[i].add_actor(this_slats[i]);
			new_slats[i] = new Clutter.Clone(new_slide);
			groups[i].add_actor(new_slats[i]);

			// clip clones
			this_slats[i].set_clip(width * i, 0,
			                       width, slide.parent.height);
			new_slats[i].set_clip(width * i, 0,
			                      width, slide.parent.height);

			// flip the back slats
			//new_slats[i].set_rotation(Clutter.RotateAxis.Y_AXIS,
			//                          180, width / 2 + i * width, 0, 0);
			
			// place the new slats behind the current ones
			new_slats[i].depth = 5;
		}

		// make an alpha for easing
		animation_alpha = new Clutter.Alpha.full(animation_time,
		                        Clutter.AnimationMode.EASE_IN_OUT_BACK);

		// animate
		animation_time.new_frame.connect((m) => {
			for (int i = 0; i < SLAT_COUNT; i++)
			{
				new_slats[i].set_rotation(Clutter.RotateAxis.Y_AXIS,
					              180 * animation_alpha.alpha,
					              (i + 0.5f) * width, 0, 0);
				
			}
		});

		animation_time.completed.connect(() => {
			// clean up the slats
			for (int i = 0; i < SLAT_COUNT; i++)
			{
				stack_container.remove_actor(groups[i]);
			}

			// put the new slide in place
			new_slide.x = 0;
		});
	}

	private void open_door_transition(SlideActor new_slide,
	                                  Clutter.Group stack_container,
	                                  uint length)
	{
		// zoom the new slide in
		new_slide.depth = OPEN_DEPTH;
		new_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE,
		                  length, "depth", 0);

		animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
		reparent(stack_container);
		x = slide.parent.width;

		// create left and right half clone actors
		float width = slide.parent.width / 2f;
		Clutter.Clone left = new Clutter.Clone(this),
		              right = new Clutter.Clone(this);

		left.set_clip(0, 0, width, slide.parent.height);
		right.set_clip(width, 0, width, slide.parent.height);

		// add the left and right actors
		stack_container.add_actor(left);
		stack_container.add_actor(right);

		// move the left and right sides outwards
		left.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE,
		             length / 2, "x", left.x - width * OPEN_MOVE);

		right.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE,
		              length / 2, "x", right.x + width * OPEN_MOVE);

		// animate the angles of the left and right sides
		time1 = new Clutter.Timeline((int)(OPEN_TIME * length));
		animation_alpha = new Clutter.Alpha.full(time1,
		                            Clutter.AnimationMode.EASE_IN_SINE);

		time1.new_frame.connect((m) => {
			left.set_rotation(Clutter.RotateAxis.Y_AXIS,
			                  180 * animation_alpha.alpha,
			                  0, 0, 0);

			right.set_rotation(Clutter.RotateAxis.Y_AXIS,
			                   -180 * animation_alpha.alpha,
			                   width * 2, 0, 0);
		});

		// clean up
		time1.completed.connect(() => {
			stack_container.remove_actor(left);
			stack_container.remove_actor(right);
		});

		time1.start();
	}

	private void zoom_transition(SlideActor new_slide,
	                             Clutter.Group stack_container, uint length)
	{
		switch (slide.variant)
		{
			case TransitionVariant.CENTER:
				new_slide.set_scale_full(0, 0,
				                         slide.parent.width / 2,
				                         slide.parent.height / 2);
				break;
			case TransitionVariant.TOP_LEFT:
				new_slide.set_scale_full(0, 0, 0, 0);
				break;
			case TransitionVariant.TOP_RIGHT:
				new_slide.set_scale_full(0, 0, slide.parent.width, 0);
				break;
			case TransitionVariant.BOTTOM_LEFT:
				new_slide.set_scale_full(0, 0, 0, slide.parent.height);
				break;
			case TransitionVariant.BOTTOM_RIGHT:
				new_slide.set_scale_full(0, 0,
				                         slide.parent.width,
				                         slide.parent.height);
				break;
		}
		animation_alpha = new Clutter.Alpha.full(animation_time,
		                                   Clutter.AnimationMode.EASE_OUT_SINE);
		
		animation_time.new_frame.connect((m) => {
			new_slide.set_scale(animation_alpha.alpha, animation_alpha.alpha);
		});
	}

	private void panel_transition(SlideActor new_slide,
	                              Clutter.Group stack_container, uint length)
	{
		float pos = 0;
		string property="";
		
		switch (slide.variant)
		{
			case TransitionVariant.UP:
				pos = slide.parent.height;
				property = "y";
				break;
			case TransitionVariant.DOWN:
				pos = -slide.parent.height;
				property = "y";
				break;
			case TransitionVariant.LEFT:
				pos = slide.parent.width;
				property = "x";
				break;
			default:
				pos = -slide.parent.width;
				property = "x";
				break;
		}

		time1 = new Clutter.Timeline(length / 4);
		time2 = new Clutter.Timeline(3 * length / 4);
		new_slide.set_scale_full(ZOOM_OUT_SCALE, ZOOM_OUT_SCALE,
		                         slide.parent.width / 2,
		                         slide.parent.height / 2);

		new_slide.set_property(property, pos);
		alpha1 = new Clutter.Alpha.full(time1,
		                                Clutter.AnimationMode.EASE_IN_OUT_SINE);

		time1.new_frame.connect((m) => {
			set_scale_full(ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) *
			                                (1 - alpha1.alpha),
			               ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) *
			                                (1 - alpha1.alpha),
				           slide.parent.width / 2, slide.parent.height / 2);
		});
		time1.completed.connect(() => {
			animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2,
			        property, -pos);
			
			new_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE,
			                  length / 2, property, 0.0f);
		});
		time2.completed.connect(() => {
			time1.new_frame.connect((m) => {
				new_slide.set_scale_full(ZOOM_OUT_SCALE +
				                          (1 - ZOOM_OUT_SCALE) * alpha1.alpha,
				                         ZOOM_OUT_SCALE +
				                          (1 - ZOOM_OUT_SCALE) * alpha1.alpha,
					                     slide.parent.width / 2,
					                     slide.parent.height / 2);
			});
			time1.start();
		});
		time1.start();
		time2.start();
	}

	private void spin_contents_transition(SlideActor new_slide,
	                                      Clutter.Group stack_container,
	                                      uint length)
	{
		prepare_stack_transition(false, new_slide, stack_container);

		new_slide.contents.opacity = 0;
		background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length,
		                   "opacity", 0);
		time1 = new Clutter.Timeline(length / 2);
		time2 = new Clutter.Timeline(length / 2);
		alpha1 = new Clutter.Alpha.full(time1,
		                                Clutter.AnimationMode.EASE_IN_SINE);

		alpha2 = new Clutter.Alpha.full(time2,
		                                Clutter.AnimationMode.EASE_OUT_SINE);

		float angle = slide.variant == TransitionVariant.LEFT ? -90 : 90;
		time1.completed.connect(() => {
			contents.opacity = 0;
			time2.start();
		});
		time1.new_frame.connect((m) => {
			contents.set_rotation(Clutter.RotateAxis.Y_AXIS,
			                      angle * alpha1.alpha,
			                      slide.parent.width / 2, 0, 0);
		});
		time2.new_frame.connect((m) => {
			new_slide.contents.opacity = 255;
			new_slide.contents.set_rotation(Clutter.RotateAxis.Y_AXIS,
			                                -angle * (1 - alpha2.alpha),
			                                 slide.parent.width / 2, 0, 0);
		});
		time1.start();
	}

	private void swing_contents_transition(SlideActor new_slide,
	                                       Clutter.Group stack_container,
	                                       uint length)
	{
		prepare_stack_transition(false, new_slide, stack_container);

		new_slide.contents.opacity = 0;
		background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE,
		                   length, "opacity", 0);
		alpha1 = new Clutter.Alpha.full(animation_time,
		                                Clutter.AnimationMode.EASE_IN_SINE);
		                                
		alpha2 = new Clutter.Alpha.full(animation_time,
		                                Clutter.AnimationMode.EASE_OUT_SINE);
		                                
		animation_alpha = new Clutter.Alpha.full(animation_time,
		                                         Clutter.AnimationMode.LINEAR);
		
		animation_time.new_frame.connect((m) => {
			unowned GLib.List<Clutter.Actor>* itr;
			contents.opacity = clamp_opacity(455 - 555 * alpha1.alpha);
			new_slide.contents.opacity = clamp_opacity(-100 + 400 * alpha2.alpha);
			
			for (itr = contents.get_children(); itr != null; itr = itr->next)
			{
				((Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS,
				                                  540 * alpha1.alpha,
				                                  0, 0, 0);
			}
			for (itr = new_slide.contents.get_children();
			     itr != null; itr = itr->next)
			{
				((Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS,
				                                  -540 * (1 - alpha2.alpha),
				                                  0, 0, 0);
			}
		});
	}

	private void slide_contents_transition(SlideActor new_slide,
	                                       Clutter.Group stack_container,
	                                       uint length)
	{
		prepare_stack_transition(false, new_slide, stack_container);

		background.animate(EASE_SLIDE, length, "opacity", 0);
		
		switch (slide.variant)
		{
			case TransitionVariant.RIGHT:
				new_slide.contents.x = -slide.parent.width;
				new_slide.contents.animate(EASE_SLIDE, length, "x", 0);

				contents.animate(EASE_SLIDE,
				                 length, "x", -new_slide.contents.x);
				break;
			case TransitionVariant.LEFT:
				new_slide.contents.x = slide.parent.width;
				new_slide.contents.animate(EASE_SLIDE, length, "x", 0);

				contents.animate(EASE_SLIDE,
				                 length, "x", -new_slide.contents.x);
				break;
			case TransitionVariant.UP:
				new_slide.contents.y = slide.parent.height;
				new_slide.contents.animate(EASE_SLIDE, length, "y", 0);

				contents.animate(EASE_SLIDE,
				                 length, "y", -new_slide.contents.y);
				break;
			case TransitionVariant.DOWN:
				new_slide.contents.y = -slide.parent.height;
				new_slide.contents.animate(EASE_SLIDE, length, "y", 0);

				contents.animate(EASE_SLIDE,
				                 length, "y", -new_slide.contents.y);
				break;
		}
	}

	private void spring_contents_transition(SlideActor new_slide,
	                                        Clutter.Group stack_container,
	                                        uint length)
	{
		prepare_stack_transition(false, new_slide, stack_container);

		background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length,
		                   "opacity", 0);

		switch (slide.variant)
		{
			case TransitionVariant.UP:
				new_slide.contents.y = slide.parent.height * 1.2f;
				new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC,
				                           length, "y", 0);
				contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC,
				                 length, "y", -slide.parent.height * 1.2);
				break;
			case TransitionVariant.DOWN:
				new_slide.contents.y = -slide.parent.height * 1.2f;
				new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC,
				                           length, "y", 0);
				contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC,
				                 length, "y", slide.parent.height * 1.2);
				break;
		}
	}

	private void zoom_contents_transition(SlideActor new_slide,
	                                      Clutter.Group stack_container,
	                                      uint length)
	{
		prepare_stack_transition(slide.variant == TransitionVariant.OUT,
		                         new_slide, stack_container);

		animation_alpha = new Clutter.Alpha.full(animation_time,
		                                Clutter.AnimationMode.EASE_IN_OUT_SINE);

		background.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
		switch (slide.variant)
		{
			case TransitionVariant.IN:
				new_slide.contents.set_scale_full(0, 0,
				                                  slide.parent.width / 2,
				                                  slide.parent.height / 2);

				contents.set_scale_full(1, 1,
				                        slide.parent.width / 2,
				                        slide.parent.height / 2);

				contents.animate(Clutter.AnimationMode.LINEAR, length / 2, "opacity", 0);
				animation_time.new_frame.connect((m) => {
					new_slide.contents.set_scale(animation_alpha.alpha,
					                             animation_alpha.alpha);

					contents.set_scale(1.0 + 2 * animation_alpha.alpha,
					   	               1.0 + 2 * animation_alpha.alpha);
				});
				break;
			case TransitionVariant.OUT:
				new_slide.contents.set_scale_full(0, 0,
				                                  slide.parent.width / 2,
				                                  slide.parent.height / 2);

				contents.set_scale_full(1, 1,
				                        slide.parent.width / 2,
				                        slide.parent.height / 2);

				new_slide.contents.opacity = 0;
				new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_SINE,
				                           length / 2, "opacity", 255);
				animation_time.new_frame.connect((m) => {
					new_slide.contents.set_scale(1.0 + 2 * (1 - animation_alpha.alpha),
						                         1.0 + 2 * (1 - animation_alpha.alpha));
					contents.set_scale(1 - animation_alpha.alpha,
					   	               1 - animation_alpha.alpha);
				});
				break;
		}
	}

	private double min(double a, double b)
	{
		return a > b ? b : a;
	}

	private double max(double a, double b)
	{
		return a > b ? a : b;
	}

	private uint8 clamp_opacity(double o)
	{
		return (uint8)(max(0, min(255, o)));
	}
}

