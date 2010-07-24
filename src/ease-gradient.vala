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
 * Gradient representation, using {@link Color}.
 */
public class Ease.Gradient : GLib.Object
{
	/**
	 * The format string for converting gradients to strings.
	 */
	private const string STR = "%s%s%s%s%s%s";
	
	/**
	 * The string placed between each color in a string representation.
	 */
	private const string SPLIT = "|";	
	
	/**
	 * The starting {@link Color} of the gradient.
	 */
	public Color start { get; set; }
	
	/**
	 * The ending {@link Color} of the gradient.
	 */
	public Color end { get; set; }
	
	/**
	 * The {@link GradientMode} of the gradient.
	 */
	public GradientMode mode { get; set; }
	
	/**
	 * The angle, in radians, of the gradient, if it is linear.
	 */
	public double angle { get; set; }
	
	/**
	 * Creates a new linear gradient, with the specified colors.
	 */
	public Gradient(Color start_color, Color end_color)
	{
		start = start_color;
		end = end_color;
		mode = GradientMode.LINEAR;
	}
	
	/**
	 * Creates a new mirrored linear gradient, with the specified colors.
	 */
	public Gradient.mirrored(Color start_color, Color end_color)
	{
		this(start_color, end_color);
		mode = GradientMode.LINEAR_MIRRORED;
	}
	
	/**
	 * Creates a new linear gradient, with the specified colors.
	 */
	public Gradient.radial(Color start_color, Color end_color)
	{
		this(start_color, end_color);
		mode = GradientMode.RADIAL;
	}
	
	/**
	 * Creates a Gradient from a string representation.
	 */
	public Gradient.from_string(string str)
	{
		var split = str.replace(" ", "").split(SPLIT);
		start = new Color.from_string(split[0]);
		end = new Color.from_string(split[1]);
		mode = GradientMode.from_string(split[2]);
		angle = split[3].to_double();
	}
	
	/**
	 * Returns a string representation of this Gradient.
	 */
	public string to_string()
	{
		return STR.printf(start.to_string(), SPLIT,
		                  end.to_string(), SPLIT,
		                  mode.to_string(), SPLIT,
		                  angle.to_string());
	}
	
	/**
	 * Reverses the Gradient.
	 */
	public void flip()
	{
		var temp = end;
		end = start;
		start = temp;
	}
	
	/**
	 * Renders the gradient to the given Cairo context at the specified size.
	 *
	 * @param cr The Cairo context to render to.
	 * @param width The width of the rendered rectangle.
	 * @param height The height of the rendered rectangle.
	 */
	public void cairo_render_rect(Cairo.Context cr, int width, int height)
	{
		cr.save();
		cr.rectangle(0, 0, width, height);
		
		Cairo.Pattern pattern;
		switch (mode)
		{
			case GradientMode.LINEAR:				
				pattern = new Cairo.Pattern.linear(0, 0, 0, height);
				pattern.add_color_stop_rgba(0, start.red, start.green,
						                    start.blue, start.alpha);
				pattern.add_color_stop_rgba(1, end.red, end.green,
						                    end.blue, end.alpha);
				break;
			case GradientMode.LINEAR_MIRRORED:
				pattern = new Cairo.Pattern.linear(0, 0, 0, height);
				pattern.add_color_stop_rgba(0, start.red, start.green,
						                    start.blue, start.alpha);
				pattern.add_color_stop_rgba(0.5, end.red, end.green,
						                    end.blue, end.alpha);
				pattern.add_color_stop_rgba(1, start.red, start.green,
						                    start.blue, start.alpha);
				break;
			default: // radial
				pattern = new Cairo.Pattern.radial(width / 2, height / 2, 0,
				                                       width / 2, height / 2,
				                                       width / 2);
				pattern.add_color_stop_rgba(0, start.red, start.green,
						                    start.blue, start.alpha);
				pattern.add_color_stop_rgba(1, end.red, end.green,
						                    end.blue, end.alpha);
				break;
		}
		
		cr.set_source(pattern);
		cr.fill();
		
		cr.restore();
	}
}

/**
 * The {@link Gradient} types provided by Ease.
 */
public enum Ease.GradientMode
{
	/**
	 * A linear gradient, from top to bottom.
	 */
	LINEAR,
	
	/**
	 * A mirrored linear gradient, with the "end" color in the middle and the
	 * "start" color on both ends.
	 */
	LINEAR_MIRRORED,
	
	/**
	 * A radial gradient, with the "start" color in the center and the "end"
	 * color on the outsides.
	 */
	RADIAL;
	
	/**
	 * Returns a string representation of this GradientMode.
	 */
	public string to_string()
	{
		switch (this)
		{
			case LINEAR: return Theme.GRAD_LINEAR;
			case LINEAR_MIRRORED: return Theme.GRAD_LINEAR_MIRRORED;
			case RADIAL: return Theme.GRAD_RADIAL;
		}
		return "undefined";
	}
	
	/**
	 * Creates a GradientMode from a string representation.
	 */
	public static GradientMode from_string(string str)
	{
		switch (str)
		{
			case Theme.GRAD_LINEAR: return LINEAR;
			case Theme.GRAD_LINEAR_MIRRORED: return LINEAR_MIRRORED;
			case Theme.GRAD_RADIAL: return RADIAL;
		}
		
		warning("%s is not a gradient type", str);
		return LINEAR;
	}
}
