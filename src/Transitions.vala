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
	                                               
	private const Transition[] transitions = {
		{ TransitionType.NONE },
		{ TransitionType.FADE },
		{ TransitionType.SLIDE, directions },
		{ TransitionType.DROP },
		{ TransitionType.PIVOT,
		               { TransitionVariant.TOP_LEFT,
		                            TransitionVariant.TOP_RIGHT,
		                            TransitionVariant.BOTTOM_LEFT,
		                            TransitionVariant.BOTTOM_RIGHT } },
		{ TransitionType.FLIP,
		               { TransitionVariant.TOP_TO_BOTTOM,
		                            TransitionVariant.BOTTOM_TO_TOP,
		                            TransitionVariant.LEFT_TO_RIGHT,
		                            TransitionVariant.RIGHT_TO_LEFT } },
		{ TransitionType.REVOLVING_DOOR,
		               directions },
		{ TransitionType.REVEAL, directions },
		{ TransitionType.FALL },
		{ TransitionType.SLATS },
		{ TransitionType.OPEN_DOOR },
		{ TransitionType.ZOOM,
		               { TransitionVariant.CENTER,
		                            TransitionVariant.TOP_LEFT,
		                            TransitionVariant.TOP_RIGHT,
		                            TransitionVariant.BOTTOM_LEFT,
		                            TransitionVariant.BOTTOM_RIGHT } },
		{ TransitionType.PANEL, directions },
		{ TransitionType.SPIN_CONTENTS,
		               { TransitionVariant.LEFT,
		                            TransitionVariant.RIGHT } },
		{ TransitionType.SWING_CONTENTS },
		{ TransitionType.SLIDE_CONTENTS,
		               directions },
		{ TransitionType.SPRING_CONTENTS,
		               { TransitionVariant.UP,
		                            TransitionVariant.DOWN } },
		{ TransitionType.ZOOM_CONTENTS,
		               { TransitionVariant.IN,
		                            TransitionVariant.OUT } }
	};
	
	public static int size { get { return transitions.length; } }
	
	/**
	 * Returns the string name of a transition.
	 *
	 * @param type The {@link TransitionType} to find a name for..
	 */
	public static string get_name(TransitionType type)
	{
		switch (type)
		{
			case TransitionType.NONE:
				return _("None");
			case TransitionType.FADE:
				return _("Fade");
			case TransitionType.SLIDE:
				return _("Slide");
			case TransitionType.DROP:
				return _("Drop");
			case TransitionType.PIVOT:
				return _("Pivot");
			case TransitionType.FLIP:
				return _("Flip");
			case TransitionType.REVOLVING_DOOR:
				return _("Revolving Door");
			case TransitionType.REVEAL:
				return _("Reveal");
			case TransitionType.FALL:
				return _("Fall");
			case TransitionType.SLATS:
				return _("Slats");
			case TransitionType.OPEN_DOOR:
				return _("Open Door");
			case TransitionType.ZOOM:
				return _("Zoom");
			case TransitionType.PANEL:
				return _("Panel");
			case TransitionType.SPIN_CONTENTS:
				return _("Spin Contents");
			case TransitionType.SPRING_CONTENTS:
				return _("Spring Contents");
			case TransitionType.SWING_CONTENTS:
				return _("Swing Contents");
			case TransitionType.SLIDE_CONTENTS:
				return _("Slide Contents");
			default: // ZOOM_CONTENTS
				return _("Zoom Contents");
		}
	}
	
	/**
	 * Returns the string name of a variant.
	 *
	 * @param variant The {@link TransitionVariant} to find a name for.
	 */
	public static string get_variant_name(TransitionVariant variant)
	{
		switch (variant)
		{
			case TransitionVariant.UP:
				return _("Up");
			case TransitionVariant.DOWN:
				return _("Down");
			case TransitionVariant.LEFT:
				return _("Left");
			case TransitionVariant.RIGHT:
				return _("Right");
			case TransitionVariant.BOTTOM:
				return _("Bottom");
			case TransitionVariant.TOP:
				return _("Top");
			case TransitionVariant.CENTER:
				return _("Center");
			case TransitionVariant.TOP_LEFT:
				return _("Top Left");
			case TransitionVariant.TOP_RIGHT:
				return _("Top Right");
			case TransitionVariant.BOTTOM_LEFT:
				return _("Bottom Left");
			case TransitionVariant.BOTTOM_RIGHT:
				return _("Bottom Right");
			case TransitionVariant.TOP_TO_BOTTOM:
				return _("Top to Bottom");
			case TransitionVariant.BOTTOM_TO_TOP:
				return _("Bottom to Top");
			case TransitionVariant.LEFT_TO_RIGHT:
				return _("Left to Right");
			case TransitionVariant.RIGHT_TO_LEFT:
				return _("Right to Left");
			case TransitionVariant.IN:
				return _("In");
			default: // OUT
				return _("Out");
		}
	}
	
	/**
	 * Returns a {@link Transition} struct for the given {@link TransitionType}.
	 *
	 * @param type The {@link TransitionType} to find the transition for.
	 */
	public static Transition? get_transition(TransitionType type)
	{
		for (int i = 0; i < transitions.length; i++)
		{
			if (transitions[i].type == type)
			{
				return transitions[i];
			}
		}
		
		return null;
	}
	
	/**
	 * Returns the index of the given {@link TransitionType}.
	 *
	 * @param type The {@link TransitionType} to find the index of.
	 */
	public static int? get_index(TransitionType type)
	{
		for (int i = 0; i < transitions.length; i++)
		{
			if (transitions[i].type == type)
			{
				return i;
			}
		}
		
		return null;
	}
	
	/**
	 * Returns the {@link TransitionType} for a given index.
	 *
	 * @param index The index to find the {@link TransitionType} of.
	 */
	public static TransitionType transition_for_index(int index)
	{
		return transitions[index].type;
	}
	
	/**
	 * Returns the variants for a given index.
	 *
	 * @param index The index to find the variants of.
	 */
	public static TransitionVariant[] variants_for_index(int index)
	{
		return transitions[index].variants;
	}
	
	/**
	 * Returns the variants of a given {@link TransitionType}.
	 *
	 * @param t The {@link TransitionType} to find the variants of.
	 */
	public static TransitionVariant[] variants_for_transition(TransitionType t)
	{
		return variants_for_index(get_index(t));
	}
	
	/**
	 * Returns the names of all transitions.
	 */
	public static string[] names()
	{
		var names = new string[transitions.length];
		
		for (int i = 0; i < transitions.length; i++)
		{
			names[i] = get_name(transitions[i].type);
		}
		
		return names;
	}
	
	/**
	 * Returns a specific transition name
	 *
	 * @param index The index of the transition to find the name of.
	 */
	public static string name(int index)
	{
		return get_name(transitions[index].type);
	}
	
	/**
	 * Runs a test print of all transitions and variants.
	 */
	public static void test()
	{
		stdout.printf("%i Transitions:\n", (int)transitions.length);
		
		for (int i = 0; i < transitions.length; i++)
		{
			stdout.printf("\t%s has %i variants:\n",
			              get_name(transitions[i].type),
			              transitions[i].variants.length);
			
			for (int j = 0; j < transitions[i].variants.length; i++)
			{
				stdout.printf("\t\t%s\n",
				              get_variant_name(transitions[i].variants[j]));
			}
		}
	}
}

public struct Ease.Transition
{
	public TransitionType type;
	public TransitionVariant[] variants;
}

/**
 * All transitions available in Ease
 */
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

/**
 * All transition variants available in Ease. Each transition uses a subset.
 */
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

