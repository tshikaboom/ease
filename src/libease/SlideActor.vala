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
	private Slide slide;

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
	public const Clutter.AnimationMode EASE_SLIDE =
		Clutter.AnimationMode.EASE_IN_OUT_SINE;
		
	public const Clutter.AnimationMode EASE_DROP =
		Clutter.AnimationMode.EASE_OUT_BOUNCE;
	
	public const Clutter.AnimationMode EASE_PIVOT =
		Clutter.AnimationMode.EASE_OUT_SINE;
		
	public const float FLIP_DEPTH = -400;
	public const float ZOOM_OUT_SCALE = 0.75f;
	private const float OPEN_DEPTH = -3000;
	private const float OPEN_MOVE = 0.15f;
	private const float OPEN_TIME = 0.8f;
	
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
				stdout.printf("Error loading background: %s", e.message);
			}
		}
		else // the background is a solid color
		{
			background = new Clutter.Rectangle();
			((Clutter.Rectangle)background).set_color(slide.background_color);
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
		uint length = (uint)max(10, slide.transition_time * 1000);
		float xpos = 0, ypos = 0, angle = 90;
		var property = "";
		
		animation_time = new Clutter.Timeline(length);
		animation_time.start();
	
		switch (slide.transition)
		{
			case "Fade":
				prepare_slide_transition(new_slide, stack_container);
				new_slide.opacity = 0;
				new_slide.animate(Clutter.AnimationMode.LINEAR,
				                  length, "opacity", 255);
				break;
			
			case "Slide":
				switch (slide.variant)
				{
					case "Up":
						new_slide.y = slide.parent.height;
						new_slide.animate(EASE_SLIDE, length, "y", 0);
						animate(EASE_SLIDE, length, "y", -new_slide.y);
						break;
					case "Down":
						new_slide.y = -slide.parent.height;
						new_slide.animate(EASE_SLIDE, length, "y", 0);
						animate(EASE_SLIDE, length, "y", -new_slide.y);
						break;
					case "Left":
						new_slide.x = slide.parent.width;
						new_slide.animate(EASE_SLIDE, length, "x", 0);
						animate(EASE_SLIDE, length, "x", -new_slide.x);
						break;
					case "Right":
						new_slide.x = -slide.parent.width;
						new_slide.animate(EASE_SLIDE, length, "x", 0);
						animate(EASE_SLIDE, length, "x", -new_slide.x);
						break;
				}
				break;
			
			case "Drop":
				new_slide.y = -slide.parent.height;
				new_slide.animate(EASE_DROP, length, "y", 0);
				break;
			
			case "Pivot":
				switch (slide.variant)
				{
					case "Top Right":
						xpos = slide.parent.width;
						angle = -90;
						break;
					case "Bottom Left":
						ypos = slide.parent.height;
						angle = -90;
						break;
					case "Bottom Right":
						xpos = slide.parent.width;
						ypos = slide.parent.height;
						break;
				}
				new_slide.set_rotation(Clutter.RotateAxis.Z_AXIS,
				                       angle, xpos, ypos, 0);
				animation_alpha = new Clutter.Alpha.full(animation_time,
				                                         EASE_PIVOT);
				animation_time.new_frame.connect((m) => {
					new_slide.set_rotation(Clutter.RotateAxis.Z_AXIS,
					                       angle * (1 - animation_alpha.get_alpha()),
					                       xpos, ypos, 0);
				});
				break;
				
			case "Open Door":
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
					                  180 * animation_alpha.get_alpha(),
					                  0, 0, 0);
					                  
					right.set_rotation(Clutter.RotateAxis.Y_AXIS,
					                   -180 * animation_alpha.get_alpha(),
					                   width * 2, 0, 0);
				});
				
				// clean up
				time1.completed.connect(() => {
					stack_container.remove_actor(left);
					stack_container.remove_actor(right);
				});
				
				time1.start();
				
				break;
			}
			
			case "Reveal":
				// TODO: make this transition not a total hack
				((Clutter.Container)get_parent()).raise_child(this, new_slide);
				
				switch (slide.variant)
				{
					case "Top":
						new_slide.y = slide.parent.height;
						animate(EASE_SLIDE, length, "y", -new_slide.y);
						new_slide.y = 0;
						break;
					case "Bottom":
						new_slide.y = -slide.parent.height;
						animate(EASE_SLIDE, length, "y", -new_slide.y);
						new_slide.y = 0;
						break;
					case "Left":
						new_slide.x = slide.parent.width;
						this.animate(EASE_SLIDE, length, "x", -new_slide.x);
						new_slide.x = 0;
						break;
					case "Right":
						new_slide.x = -slide.parent.width;
						animate(EASE_SLIDE, length, "x", -new_slide.x);
						new_slide.x = 0;
						break;
				}
				break;
			
			case "Flip":
				new_slide.opacity = 0;				
				time1 = new Clutter.Timeline(length / 2);
				time2 = new Clutter.Timeline(length / 2);
				alpha1 = new Clutter.Alpha.full(time1,
				                       Clutter.AnimationMode.EASE_IN_SINE);
				alpha2 = new Clutter.Alpha.full(time2,
				                       Clutter.AnimationMode.EASE_OUT_SINE);
				switch (slide.variant)
				{
					case "Bottom to Top":
						time1.new_frame.connect((m) => {
							set_rotation(Clutter.RotateAxis.X_AXIS, 90 * alpha1.get_alpha(), 0, slide.parent.height / 2, 0);
							depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
						});
						time2.new_frame.connect((m) => {
							new_slide.opacity = 255;
							new_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
							new_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * (1 - alpha2.get_alpha()), 0, slide.parent.height / 2, 0);
						});
						break;
					case "Top to Bottom":
						time1.new_frame.connect((m) => {
							set_rotation(Clutter.RotateAxis.X_AXIS, -90 * alpha1.get_alpha(), 0, slide.parent.height / 2, 0);
							depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
						});
						time2.new_frame.connect((m) => {
							new_slide.opacity = 255;
							new_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
							new_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90 * (1 - alpha2.get_alpha()), 0, slide.parent.height / 2, 0);
						});
						break;
					case "Left to Right":
						time1.new_frame.connect((m) => {
							set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * alpha1.get_alpha(), slide.parent.width / 2, 0, 0);
							depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
						});
						time2.new_frame.connect((m) => {
							new_slide.opacity = 255;
							new_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
							new_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * (1 - alpha2.get_alpha()), slide.parent.width / 2, 0, 0);
						});
						break;
					case "Right to Left":
						time1.new_frame.connect((m) => {
							set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * alpha1.get_alpha(), slide.parent.width / 2, 0, 0);
							depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
						});
						time2.new_frame.connect((m) => {
							new_slide.opacity = 255;
							new_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
							new_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * (1 - alpha2.get_alpha()), slide.parent.width / 2, 0, 0);
						});
						break;
				}
				time1.completed.connect(() => {
					opacity = 0;
					new_slide.depth = FLIP_DEPTH;
					time2.start();
				});
				time1.start();
				break;
			
			case "Revolving Door":
				depth = 1; //ugly, but works
				animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_OUT_SINE);
				switch (slide.variant)
				{
					case "Left":
						new_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90, 0, 0, 0);
						animation_time.new_frame.connect((m) => {
							new_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * (1 - animation_alpha.get_alpha()), 0, 0, 0);
							set_rotation(Clutter.RotateAxis.Y_AXIS, -110 * animation_alpha.get_alpha(), 0, 0, 0);
						});
						break;
					case "Right":
						new_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90, slide.parent.width, 0, 0);
						animation_time.new_frame.connect((m) => {
							new_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * (1 - animation_alpha.get_alpha()), slide.parent.width, 0, 0);
							set_rotation(Clutter.RotateAxis.Y_AXIS, 110 * animation_alpha.get_alpha(), slide.parent.width, 0, 0);
						});
						break;
					case "Top":
						new_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90, 0, 0, 0);
						animation_time.new_frame.connect((m) => {
							new_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * (1 - animation_alpha.get_alpha()), 0, 0, 0);
							set_rotation(Clutter.RotateAxis.X_AXIS, 110 * animation_alpha.get_alpha(), 0, 0, 0);
						});
						break;
					case "Bottom":
						new_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90, 0, slide.parent.height, 0);
						animation_time.new_frame.connect((m) => {
							new_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90 * (1 - animation_alpha.get_alpha()), 0, slide.parent.height, 0);
							set_rotation(Clutter.RotateAxis.X_AXIS, -110 * animation_alpha.get_alpha(), 0, slide.parent.height, 0);
						});
						break;
				}
				break;
			
			case "Fall":
				depth = 1; //ugly, but works
				animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_QUART);
				animation_time.new_frame.connect((m) => {
					set_rotation(Clutter.RotateAxis.X_AXIS, -90 * animation_alpha.get_alpha(), 0, slide.parent.height, 0);
				});
				break;
			
			case "Spin Contents":
				prepare_stack_transition(false, new_slide, stack_container);
			
				new_slide.contents.opacity = 0;	
				background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);			
				time1 = new Clutter.Timeline(length / 2);
				time2 = new Clutter.Timeline(length / 2);
				alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_SINE);
				alpha2 = new Clutter.Alpha.full(time2, Clutter.AnimationMode.EASE_OUT_SINE);
				angle = slide.variant == "Left" ? -90 : 90;
				time1.completed.connect(() => {
					contents.opacity = 0;
					time2.start();
				});
				time1.new_frame.connect((m) => {
					contents.set_rotation(Clutter.RotateAxis.Y_AXIS, angle * alpha1.get_alpha(), slide.parent.width / 2, 0, 0);
				});
				time2.new_frame.connect((m) => {
					new_slide.contents.opacity = 255;
					new_slide.contents.set_rotation(Clutter.RotateAxis.Y_AXIS, -angle * (1 - alpha2.get_alpha()), slide.parent.width / 2, 0, 0);
				});
				time1.start();
				break;
			
			case "Swing Contents":
				prepare_stack_transition(false, new_slide, stack_container);
			
				new_slide.contents.opacity = 0;	
				background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
				alpha1 = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_SINE);
				alpha2 = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
				animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.LINEAR);
				animation_time.new_frame.connect((m) => {
					unowned GLib.List<Clutter.Actor>* itr;
					contents.opacity = clamp_opacity(455 - 555 * alpha1.get_alpha());
					new_slide.contents.opacity = clamp_opacity(-100 + 400 * alpha2.get_alpha());
					for (itr = contents.get_children(); itr != null; itr = itr->next)
					{
						((Clutter.Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS, 540 * alpha1.get_alpha(), 0, 0, 0);
					}
					for (itr = new_slide.contents.get_children(); itr != null; itr = itr->next)
					{
						((Clutter.Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS, -540 * (1 - alpha2.get_alpha()), 0, 0, 0);
					}
				});
				break;
			
			case "Zoom":
				switch (slide.variant)
				{
					case "Center":
						new_slide.set_scale_full(0, 0, slide.parent.width / 2, slide.parent.height / 2);
						break;
					case "Top Left":
						new_slide.set_scale_full(0, 0, 0, 0);
						break;
					case "Top Right":
						new_slide.set_scale_full(0, 0, slide.parent.width, 0);
						break;
					case "Bottom Left":
						new_slide.set_scale_full(0, 0, 0, slide.parent.height);
						break;
					case "Bottom Right":
						new_slide.set_scale_full(0, 0, slide.parent.width, slide.parent.height);
						break;
				}
				animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
				animation_time.new_frame.connect((m) => {
					new_slide.set_scale(animation_alpha.get_alpha(), animation_alpha.get_alpha());
				});
				//new_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_x", 1);
				//new_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_y", 1);
				break;
			
			case "Slide Contents":
				prepare_stack_transition(false, new_slide, stack_container);
			
				background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
				switch (slide.variant)
				{
					case "Right":
						new_slide.contents.x = -slide.parent.width;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
						contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", -new_slide.contents.x);
						break;
					case "Left":
						new_slide.contents.x = slide.parent.width;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
						contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", -new_slide.contents.x);
						break;
					case "Up":
						new_slide.contents.y = slide.parent.height;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
						contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", -new_slide.contents.y);
						break;
					case "Down":
						new_slide.contents.y = -slide.parent.height;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
						contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", -new_slide.contents.y);
						break;
				}
				break;
			
			case "Spring Contents":
				prepare_stack_transition(false, new_slide, stack_container);
			
				background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
				switch (slide.variant)
				{
					case "Up":
						new_slide.contents.y = slide.parent.height * 1.2f;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", 0);
						contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", -slide.parent.height * 1.2);
						break;
					case "Down":
						new_slide.contents.y = -slide.parent.height * 1.2f;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", 0);
						contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", slide.parent.height * 1.2);
						break;
				}
				break;
			
			case "Zoom Contents":
				prepare_stack_transition(slide.variant == "Out",
				                         new_slide, stack_container);
				                         
				animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_OUT_SINE);
				background.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
				switch (slide.variant)
				{
					case "In":
						new_slide.contents.set_scale_full(0, 0, slide.parent.width / 2, slide.parent.height / 2);
						contents.set_scale_full(1, 1, slide.parent.width / 2, slide.parent.height / 2);
						contents.animate(Clutter.AnimationMode.LINEAR, length / 2, "opacity", 0);
						animation_time.new_frame.connect((m) => {
							new_slide.contents.set_scale(animation_alpha.get_alpha(),
								                            animation_alpha.get_alpha());
							contents.set_scale(1.0 + 2 * animation_alpha.get_alpha(),
							   	                        1.0 + 2 * animation_alpha.get_alpha());
						});
						break;
					case "Out":
						new_slide.contents.set_scale_full(0, 0, slide.parent.width / 2, slide.parent.height / 2);
						contents.set_scale_full(1, 1, slide.parent.width / 2, slide.parent.height / 2);
						new_slide.contents.opacity = 0;
						new_slide.contents.animate(Clutter.AnimationMode.EASE_IN_SINE, length / 2, "opacity", 255);
						animation_time.new_frame.connect((m) => {
							new_slide.contents.set_scale(1.0 + 2 * (1 - animation_alpha.get_alpha()),
								                            1.0 + 2 * (1 - animation_alpha.get_alpha()));
							contents.set_scale(1 - animation_alpha.get_alpha(),
							   	                         1 - animation_alpha.get_alpha());
						});
						break;
				}
				break;
			
			case "Panel":
				switch (slide.variant)
				{
					case "Up":
						xpos = slide.parent.height;
						property = "y";
						break;
					case "Down":
						xpos = -slide.parent.height;
						property = "y";
						break;
					case "Left":
						xpos = slide.parent.width;
						property = "x";
						break;
					case "Right":
						xpos = -slide.parent.width;
						property = "x";
						break;
				}
			
				time1 = new Clutter.Timeline(length / 4);
				time2 = new Clutter.Timeline(3 * length / 4);
				new_slide.set_scale_full(ZOOM_OUT_SCALE, ZOOM_OUT_SCALE, slide.parent.width / 2, slide.parent.height / 2);
				new_slide.set_property(property, xpos);
				alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_OUT_SINE);
			
				time1.new_frame.connect((m) => {
					set_scale_full(ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * (1 - alpha1.get_alpha()),
						                     ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * (1 - alpha1.get_alpha()),
						                     slide.parent.width / 2,
						                     slide.parent.height / 2);
				});
				time1.completed.connect(() => {
					animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2, property, -xpos);
					new_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2, property, 0.0f);
				});
				time2.completed.connect(() => {
					time1.new_frame.connect((m) => {
						new_slide.set_scale_full(ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * alpha1.get_alpha(),
							                         ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * alpha1.get_alpha(),
							                         slide.parent.width / 2,
							                         slide.parent.height / 2);
					});
					time1.start();
				});
				time1.start();
				time2.start();
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

