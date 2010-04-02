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

namespace Ease
{
	public static class Transitions : GLib.Object
	{
		private static Gee.ArrayList<Transition> Transitions;
		
		public static int size { get { return Transitions.size; } }
		
		public static void init()
		{
			Transitions = new Gee.ArrayList<Transition>();
			add_transition("None", {}, 0);
			add_transition("Fade", {}, 0);
			add_transition("Slide", { "Up", "Down", "Left", "Right" }, 4);
			add_transition("Drop", {}, 0);
			add_transition("Pivot", { "Top Left", "Top Right", "Bottom Left", "Bottom Right" }, 4);
			add_transition("Flip", { "Top to Bottom", "Bottom to Top", "Left to Right", "Right to Left" }, 4);
			add_transition("Revolving Door", { "Top", "Bottom", "Left", "Right" }, 4);
			add_transition("Fall", {}, 0);
			add_transition("Zoom", { "Center", "Top Left", "Top Right", "Bottom Left", "Bottom Right" }, 5);
			add_transition("Panel", { "Up", "Down", "Left", "Right" }, 4);
			add_transition("Spin Contents", { "Left", "Right" }, 2);
			add_transition("Swing Contents", {}, 0);
			add_transition("Slide Contents", { "Up", "Down", "Left", "Right" }, 4);
			add_transition("Spring Contents", { "Up", "Down" }, 2);
			add_transition("Zoom Contents", { "In", "Out" }, 2);
		}
		
		public static string get_name(int i)
		{
			return Transitions.get(i).name;
		}
		
		public static int get_transition_id(string name)
		{
			for (var i = 0; i < Transitions.size; i++)
			{
				if (Transitions.get(i).name == name)
				{
					return i;
				}
			}
			return 0;
		}
		
		public static int get_variant_id(string transition, string variant)
		{
			var id = get_transition_id(transition);
			for (var i = 0; i < Transitions.get(id).count; i++)
			{
				if (Transitions.get(id).variants[i] == variant)
				{
					return i;
				}
			}
			return 0;
		}
		
		public static string[] get_variants(int i)
		{
			return Transitions.get(i).variants;
		}
		
		public static int get_variant_count(int i)
		{
			return Transitions.get(i).count;
		}
		
		private static void add_transition(string n, string[] v, int c)
		{
			Transition t = new Transition();
			t.name = n;
			t.variants = v;
			t.count = c;
			Transitions.add(t);
		}
		
		private class Transition : GLib.Object
		{
			public string name { get; set; }
			public int count { get; set; }
			public string[] variants;
		}
	}
}