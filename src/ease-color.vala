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
 * Color abstraction, supporting Clutter, GDK, and Cairo colors.
 */
public class Ease.Color : GLib.Object
{
	/**
	 * The format string for converting Colors to strings.
	 */
	private const string STR = "%f%s %f%s %f%s %f";
	
	/**
	 * The string placed between each channel in a string representation.
	 */
	private const string SPLIT = ",";
	
	/**
	 * A color with the values (1, 1, 1, 1).
	 */
	public static Color white
	{
		owned get { return new Color.rgb(1, 1, 1); }
	}
	
	/**
	 * A color with the values (0, 0, 0, 1).
	 */
	public static Color black
	{
		owned get { return new Color.rgb(0, 0, 0); }
	}

	/**
	 * The red value of this color.
	 */
	public double red
	{
		get { return red_priv; }
		set
		{
			if (value < 0)
			{
				warning("red value must be >= 0, %f is not", value);
				red_priv = 0;
			}
			else if (value > 1)
			{
				warning("red value must be <= 0, %f is not", value);
				red_priv = 1;
			}
			else red_priv = value;
		}
	}
	private double red_priv;
	
	/**
	 * The green value of this color.
	 */
	public double green
	{
		get { return green_priv; }
		set
		{
			if (value < 0)
			{
				warning("green value must be >= 0, %f is not", value);
				green_priv = 0;
			}
			else if (value > 1)
			{
				warning("green value must be <= 0, %f is not", value);
				green_priv = 1;
			}
			else green_priv = value;
		}
	}
	private double green_priv;
	
	/**
	 * The blue value of this color.
	 */
	public double blue
	{
		get { return blue_priv; }
		set
		{
			if (value < 0)
			{
				warning("blue value must be >= 0, %f is not", value);
				blue_priv = 0;
			}
			else if (value > 1)
			{
				warning("blue value must be <= 0, %f is not", value);
				blue_priv = 1;
			}
			else blue_priv = value;
		}
	}
	private double blue_priv;
	
	/**
	 * The alpha (transparency) of this color.
	 */
	public double alpha
	{
		get { return alpha_priv; }
		set
		{
			if (value < 0)
			{
				warning("alpha value must be >= 0, %f is not", value);
				alpha_priv = 0;
			}
			else if (value > 1)
			{
				warning("alpha value must be <= 0, %f is not", value);
				alpha_priv = 1;
			}
			else alpha_priv = value;
		}
	}
	private double alpha_priv;
	
	/**
	 * A Clutter.Color representation of this color. Changes made to the
	 * the returned color are not reflected in this color.
	 */
	public Clutter.Color clutter
	{
		get
		{
			return { (uchar)(255 * red),
			         (uchar)(255 * green),
			         (uchar)(255 * blue),
			         (uchar)(255 * alpha) };
		}
		set
		{
			red = value.red / 255f;
			green = value.green / 255f;
			blue = value.blue / 255f;
			alpha = value.alpha / 255f;
		}
	}
	
	/**
	 * A Gdk.Color representation of this color. Changes made to the returned
	 * color are not reflected in this color. Note that GDK colors do not
	 * support an alpha value. When being set, the alpha will be set to full,
	 * when retrieved, the alpha value will be ignored.
	 */
	public Gdk.Color gdk
	{
		get
		{
			return { 0,
			         (uint16)(65535 * red),
			         (uint16)(65535 * green),
			         (uint16)(65535 * blue) };
		}
		set
		{
			red = value.red / 65535f;
			green = value.green / 65535f;
			blue = value.blue / 65535f;
			alpha = 1;
		}
	}
	
	/**
	 * Creates an opaque color.
	 */
	public Color.rgb(double r, double g, double b)
	{
		rgba(r, g, b, 1);
	}
	
	/**
	 * Creates a color.
	 *
	 * @param r The red value.
	 * @param g The green value.
	 * @param b The blue value.
	 * @param a The alpha value.
	 */
	public Color.rgba(double r, double g, double b, double a)
	{
		red = r;
		green = g;
		blue = b;
		alpha = a;
	}
	
	/**
	 * Creates a Color from a Clutter.Color. See also: {@link clutter}.
	 *
	 * @param color The Clutter color to use.
	 */
	public Color.from_clutter(Clutter.Color color)
	{
		clutter = color;
	}
	
	/**
	 * Creates a Color from a Gdk.Color. See also: {@link gdk}.
	 *
	 * @param color The Clutter color to use.
	 */
	public Color.from_gdk(Gdk.Color color)
	{
		gdk = color;
	}
	
	/**
	 * Creates a Color from a string representation created by to_string().
	 *
	 * @param str The string to create a color from.
	 */
	public Color.from_string(string str)
	{
		var split = str.replace(" ", "").split(SPLIT);
		red = split[0].to_double();
		green = split[1].to_double();
		blue = split[2].to_double();
		
		// it's ok to omit the alpha value - assumes full alpha
		if (split.length > 3) alpha = split[3].to_double();
		else alpha = 1;
	}
	
	/**
	 * Creates a string representation of a color.
	 */
	public string to_string()
	{
		return STR.printf(red, SPLIT, green, SPLIT, blue, SPLIT, alpha);
	}
	
	/**
	 * Returns a copy of this Color
	 */
	public Color copy()
	{
		return new Color.rgba(red, green, blue, alpha);
	}
	
	/**
	 * Sets the given Cairo context's color to this color.
	 *
	 * @param cr The Cairo Context to set the color for.
	 */
	public void set_cairo(Cairo.Context cr)
	{
		cr.set_source_rgba(red, green, blue, alpha);
	}
	
	/**
	 * Returns an {@link UndoAction} that will restore this Color to its current
	 * state.
	 */
	public UndoAction undo_action()
	{
		var action = new UndoAction(this, "red");
		action.add(this, "green");
		action.add(this, "blue");
		action.add(this, "alpha");
		
		return action;
	}
}
