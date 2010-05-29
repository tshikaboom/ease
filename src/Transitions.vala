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
	private const TransitionVariant[] directions = { TransitionVariant.UP,
	                                               TransitionVariant.DOWN,
	                                               TransitionVariant.LEFT,
	                                               TransitionVariant.RIGHT };
	                                               
	private static Transition[] transitions = {
		Transition() { type = TransitionType.NONE, variants = {} },
		Transition() { type = TransitionType.FADE, variants = {} },
		Transition() { type = TransitionType.SLIDE, variants = directions },
		Transition() { type = TransitionType.DROP, variants = {} },
		Transition() { type = TransitionType.PIVOT,
		               variants = { TransitionVariant.TOP_LEFT,
		                            TransitionVariant.TOP_RIGHT,
		                            TransitionVariant.BOTTOM_LEFT,
		                            TransitionVariant.BOTTOM_RIGHT } },
		Transition() { type = TransitionType.FLIP,
		               variants = { TransitionVariant.TOP_TO_BOTTOM,
		                            TransitionVariant.BOTTOM_TO_TOP,
		                            TransitionVariant.LEFT_TO_RIGHT,
		                            TransitionVariant.RIGHT_TO_LEFT } },
		Transition() { type = TransitionType.REVOLVING_DOOR, variants = directions },
		Transition() { type = TransitionType.REVEAL, variants = directions },
		Transition() { type = TransitionType.FALL, variants = {} },
		Transition() { type = TransitionType.SLATS, variants = {} },
		Transition() { type = TransitionType.OPEN_DOOR, variants = {} },
		Transition() { type = TransitionType.ZOOM,
		               variants = { TransitionVariant.CENTER,
		                            TransitionVariant.TOP_LEFT,
		                            TransitionVariant.TOP_RIGHT,
		                            TransitionVariant.BOTTOM_LEFT,
		                            TransitionVariant.BOTTOM_RIGHT } },
		Transition() { type = TransitionType.PANEL, variants = directions },
		Transition() { type = TransitionType.SPIN_CONTENTS,
		               variants = { TransitionVariant.LEFT,
		                            TransitionVariant.RIGHT } },
		Transition() { type = TransitionType.SWING_CONTENTS, variants = {} },
		Transition() { type = TransitionType.SLIDE_CONTENTS, variants = directions },
		Transition() { type = TransitionType.SPRING_CONTENTS,
		               variants = { TransitionVariant.UP,
		                            TransitionVariant.DOWN } },
		Transition() { type = TransitionType.ZOOM_CONTENTS,
		               variants = { TransitionVariant.IN,
		                            TransitionVariant.OUT } }
	};
	
	public static int size { get { return transitions.length; } }
	
	/**
	 * Returns the string name of a transition.
	 *
	 * @param type The transition type.
	 */
	public static string get_name(TransitionType type)
	{
		switch (type)
		{
			case TransitionType.NONE:
				return _("None");
				break;
			case TransitionType.FADE:
				return _("Fade");
				break;
			case TransitionType.SLIDE:
				return _("Slide");
				break;
			case TransitionType.DROP:
				return _("Drop");
				break;
			case TransitionType.PIVOT:
				return _("Pivot");
				break;
			case TransitionType.FLIP:
				return _("Flip");
				break;
			case TransitionType.REVOLVING_DOOR:
				return _("Revolving Door");
				break;
			case TransitionType.REVEAL:
				return _("Reveal");
				break;
			case TransitionType.FALL:
				return _("Fall");
				break;
			case TransitionType.SLATS:
				return _("Slats");
				break;
			case TransitionType.OPEN_DOOR:
				return _("Open Door");
				break;
			case TransitionType.ZOOM:
				return _("Zoom");
				break;
			case TransitionType.PANEL:
				return _("Panel");
				break;
			case TransitionType.SPIN_CONTENTS:
				return _("Spin Contents");
				break;
			case TransitionType.SPRING_CONTENTS:
				return _("Spring Contents");
				break;
			case TransitionType.SWING_CONTENTS:
				return _("Swing Contents");
				break;
			case TransitionType.SLIDE_CONTENTS:
				return _("Slide Contents");
				break;
			default: // ZOOM_CONTENTS
				return _("Zoom Contents");
				break;
		}
	}
	
	public string[] names()
	{
		var names = new string[transitions.length];
		
		for (int i = 0; i < transitions.length; i++)
		{
			names[i] = get_name(transitions[i].type);
		}
		
		return names;
	}
	
	/**
	 * Given a name, returns the ID of a transition.
	 * 
	 * @param name The name of the transition.
	 */
	/*public static int get_transition_id(string name)
	{
		for (var i = 0; i < transitions.length; i++)
		{
			if (get_name(transitions[i].type) == name)
			{
				return i;
			}
		}
		return 0;
	}*/
	
	/**
	 * Returns the ID of a transition, given the names of both.
	 *
	 * @param transition The name of the transition.
	 * @param variant The name of the variant.
	 */
	/*public static int get_variant_id(string transition, string variant)
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
	}*/
	
	/**
	 * Returns an array of variants, given a transition ID.
	 *
	 * @param i A transition index.
	 */
	/*public static string[] get_variants(int i)
	{
		return Transitions.get(i).variants;
	}*/
}

public struct Ease.Transition
{
	public TransitionType type;
	public TransitionVariant[] variants;
}

public enum Ease.TransitionType
{
	NONE,
	FADE,
	SLIDE,
	DROP,
	PIVOT,
	FLIP,
	REVOLVING_DOOR,
	REVEAL,
	FALL,
	SLATS,
	OPEN_DOOR,
	ZOOM,
	PANEL,
	SPIN_CONTENTS,
	SPRING_CONTENTS,
	SWING_CONTENTS,
	SLIDE_CONTENTS,
	ZOOM_CONTENTS
}

public enum Ease.TransitionVariant
{
	UP,
	DOWN,
	LEFT,
	RIGHT,
	BOTTOM,
	TOP,
	CENTER,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	TOP_TO_BOTTOM,
	BOTTOM_TO_TOP,
	LEFT_TO_RIGHT,
	RIGHT_TO_LEFT,
	IN,
	OUT
}

