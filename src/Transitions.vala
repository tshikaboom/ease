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
 * A static class containing all Ease transitions
 * 
 * The transition class is initialized at program start. It contains
 * information about each transition and each transition's variants.
 */
public static class Ease.Transitions : GLib.Object
{
	private static Gee.ArrayList<Transition> Transitions;
	
	public static int size { get { return Transitions.size; } }
	
	/**
	 * Initialize the Transitions class.
	 *
	 * Called when Ease starts.
	 */
	public static void init()
	{
		Transitions = new Gee.ArrayList<Transition>();
		string []directions = { _("Up"), _("Down"), _("Left"), _("Right") };

		add_transition(_("None"), {}, 0);
		add_transition(_("Fade"), {}, 0);
		add_transition(_("Slide"), directions, 4);
		add_transition(_("Drop"), {}, 0);
		add_transition(_("Pivot"), { _("Top Left"), _("Top Right"), _("Bottom Left"), _("Bottom Right") }, 4);
		add_transition(_("Flip"), { _("Top to Bottom"), _("Bottom to Top"), _("Left to Right"), _("Right to Left") }, 4);
		add_transition(_("Revolving Door"), directions, 4);
		add_transition(_("Reveal"), directions, 4);
		add_transition(_("Fall"), {}, 0);
		add_transition(_("Slats"), {}, 0);
		add_transition(_("Open Door"), {}, 0);
		add_transition(_("Zoom"), { _("Center"), _("Top Left"), _("Top Right"), _("Bottom Left"), _("Bottom Right") }, 5);
		add_transition(_("Panel"), directions, 4);
		add_transition(_("Spin Contents"), { _("Left"), _("Right") }, 2);
		add_transition(_("Swing Contents"), {}, 0);
		add_transition(_("Slide Contents"), directions, 4);
		add_transition(_("Spring Contents"), { _("Up"), _("Down") }, 2);
		add_transition(_("Zoom Contents"), { _("In"), _("Out") }, 2);
	}
	
	/**
	 * Returns the string name of a transition.
	 *
	 * @param i The transition index.
	 */
	public static string get_name(int i)
	{
		return Transitions.get(i).name;
	}
	
	/**
	 * Given a name, returns the ID of a transition.
	 * 
	 * @param name The name of the transition.
	 */
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
	
	/**
	 * Returns the ID of a transition, given the names of both.
	 *
	 * @param transition The name of the transition.
	 * @param variant The name of the variant.
	 */
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
	
	/**
	 * Returns an array of variants, given a transition ID.
	 *
	 * @param i A transition index.
	 */
	public static string[] get_variants(int i)
	{
		return Transitions.get(i).variants;
	}
	
	/**
	 * Returns the size of the variant array, give a transition ID.
	 *
	 * @param i A transition index.
	 */
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

