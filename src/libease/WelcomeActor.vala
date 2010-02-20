

namespace Ease
{
	public class WelcomeActor : Clutter.Rectangle
	{
		private Gee.ArrayList<WelcomeActor> others;
		private bool selected = false;
		private bool faded = false;
		
		public WelcomeActor(int w, ref Gee.ArrayList<WelcomeActor> o)
		{
			width = w;
			others = o;
			height = w * 3 / 4; // 4:3
		
			// TODO: make this an actual preview
			var color = Clutter.Color();
			color.from_hls((float)Random.next_double() * 360, 0.5f, 0.5f);
			color.from_string("Pink");
			set_color(color);
			
			color = Clutter.Color();
			color.from_string("White");
			set_border_color(color);
			set_border_width(2);
		}
		
		public void clicked()
		{
			stdout.printf("clicked!\n");
			if (selected)
			{
				// unfade the others
				foreach (var a in others)
					if (a != this)
						a.unfade();
				
				deselect();
			}
			else
			{
				// fade the others
				foreach (var a in others)
					if (a != this)
						a.fade();
				
				select();
			}
		}
		
		private void fade()
		{
			faded = true;
			animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 0.5f);
		}
		
		private void unfade()
		{
			faded = false;
			animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 1);
		}
		
		private void select()
		{
			selected = true;
			//animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 0.5f);
		}
		
		private void deselect()
		{
			selected = false;
			//animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 1);
		}
	}
}
