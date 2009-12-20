namespace Ease
{
	public static class Transitions : GLib.Object
	{
		private static Gee.ArrayList<Transition?> Transitions;
		
		public static int size { get { return Transitions.size; } }
		
		public static void init()
		{
			Transitions = new Gee.ArrayList<Transition?>();
			add_transition("None", {});
			add_transition("Fade", {});
			add_transition("Slide", { "Up", "Down", "Left", "Right" });
			add_transition("Drop", {});
			add_transition("Pivot", { "Top Left", "Top Right", "Bottom Left", "Bottom Right" });
			add_transition("Flip", { "Top to Bottom", "Bottom to Top", "Left to Right", "Right to Left" });
			add_transition("Revolving Door", { "Top", "Bottom", "Left", "Right" });
			add_transition("Fall", {});
			add_transition("Spin Contents", { "Left", "Right" });
			add_transition("Swing Contents", {});
			add_transition("Zoom", { "Center", "Top Left", "Top Right", "Bottom Left", "Bottom Right" });
			add_transition("Slide Contents", { "Up", "Down", "Left", "Right" });
			add_transition("Spring Contents", { "Up", "Down" });
			add_transition("Zoom Contents", { "In", "Out" });
			add_transition("Panel", { "Up", "Down", "Left", "Right" });
		}
		
		public static string get_name(int i)
		{
			return Transitions.get(i).name;
		}
		
		private static void add_transition(string n, string[] v)
		{
			Transition t = new Transition();
			t.name = n;
			t.variants = v;
			Transitions.add(t);
		}
		
		private class Transition : GLib.Object
		{
			public string name { get; set; }
			public string[] variants;
		}
	}
}