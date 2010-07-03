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
 * The internal representation of a slide
 *
 * A Slide is owned by a {@link Document} and has {@link Element}
 * children. The currently selected Slide is often acted upon by an
 * {@link EditorWindow}.
 */
public class Ease.Slide : GLib.Object
{
	/**
	 * The {@link Element}s contained by this Slide
	 */
	public Gee.ArrayList<Element> elements = new Gee.ArrayList<Element>();
	
	/**
	 * The Slide's transition
	 */
	public TransitionType transition { get; set; }
	
	/**
	 * The variant (if any) of the Slide's transition
	 */
	public TransitionVariant variant { get; set; }
	
	/**
	 * The duration of this Slide's transition
	 */
	public double transition_time { get; set; }
	
	/**
	 * The duration of this Slide's transition, in milliseconds
	 */
	public uint transition_msecs
	{
		get { return (uint)(transition_time * 1000); }
		set { transition_time = value / 1000f; }
	}
	
	/**
	 * If the slide advances automatically or on key press
	 */
	public bool automatically_advance { get; set; }
	
	/**
	 * If the slide advances automatically, the amount of delay
	 */
	public double advance_delay { get; set; }
	
	/**
	 * The background color, if there is no background image
	 */
	public Clutter.Color background_color;
	
	/**
	 * The background image, if one is set
	 */
	public string background_image { get; set; }
	
	/**
	 * The absolute path of the background image, if one is set.
	 */
	public string background_abs
	{
		owned get
		{
			string p = parent == null ? theme.path : parent.path;
			return Path.build_filename(p, background_image);
		}
	}
	
	/**
	 * The title of this Slide's master (unless the Slide is a master itself)
	 */
	public string title { get; set; }
	
	/**
	 * The {@link Document} that this Slide is part of
	 */
	public Document parent { get; set; }
	
	/**
	 * The {@link Theme} that this Slide is based on.
	 */
	public Theme theme { get; set; }
	
	/**
	 * The number of {@link Element}s on this Slide
	 */
	public int count { get { return elements.size; } }
	
	/**
	 * The next Slide in this Slide's {@link Document}.
	 */
	public Slide? next
	{
		owned get
		{
			for (int i = 0; i < parent.slides.size - 1; i++)
			{
				if (parent.slides.get(i) == this)
				{
					return parent.slides.get(i + 1);
				}
			}
			return null;
		}
	}
	
	/**
	 * The previous Slide in this Slide's {@link Document}.
	 */
	public Slide? previous
	{
		owned get
		{
			for (int i = 1; i < parent.slides.size; i++)
			{
				if (parent.slides.get(i) == this)
				{
					return parent.slides.get(i - 1);
				}
			}
			return null;
		}
	}
	
	/**
	 * Create a new Slide.
	 */
	public Slide() {}
	
	/**
	 * Create a new Slide assigned to a {@link Document}.
	 * 
	 * Used for loading previously saved files. 
	 *
	 * @param owner The {@link Document} this slide is a part of.
	 */
	public Slide.with_owner(Document owner)
	{
		parent = owner;
	}
	
	/**
	 * Create a Slide from a master Slide.
	 *
	 * Used for creating new Slides in a {@link Document} linked to a
	 * {@link Theme}.
	 *
	 * @param master The master slide.
	 * @param document The {@link Document} this slide is being inserted into.
	 * @param width The width, in pixels, of the Slide.
	 * @param height The height, in pixels, of the Slide.
	 * @param is_new If this Slide is part of a new {@link Document}. Sets
	 * the has_been_edited property of {@link Element}s to false.
	 */
	public Slide.from_master(Slide master, Document? document,
	                         int width, int height, bool is_new)
	{
		// set basic properties
		transition = master.transition;
		transition_time = master.transition_time;
		variant = master.variant;
		automatically_advance = master.automatically_advance;
		advance_delay = master.advance_delay;
		parent = document;
		
		// set the background
		if (master.background_image != null)
		{
			background_image = master.background_image.dup();
		}
		else
		{
			background_color = master.background_color;
		}
		
		if (master.title != null)
		{
			title = master.title.dup();
		}
		
		// add all of the master Slide's elements
		foreach (var e in master.elements)
		{
			elements.add(e.sized_element(width, height, is_new));
		}
	}
	
	/**
	 * Adds an {@link Element} to this slide at a specified index.
	 *
	 * @param index The index to add the {@link Element} at.
	 * @param e The {@link Element} to add.
	 */
	public void add_element(int index, Element e)
	{
		e.parent = this;
		elements.insert(index, e);
	}
	
	/**
	 * Creates HTML markup for this Slide.
	 * 
	 * The <div> tag for this Slide is appended to the "HTML" parameter.
	 *
	 * @param html The HTML string in its current state.
	 * @param exporter The {@link HTMLExporter}, for the path and progress.
	 * @param amount The amount progress should increase by when done.
	 * @param index The index of this slide.
	 */
	public void to_html(ref string html,
	                    HTMLExporter exporter,
	                    double amount,
	                    int index)
	{
		// create the slide opening tag
		html += "<div class=\"slide\" id=\"slide" +
		        index.to_string() + "\" ";
		
		if (background_image == null)
		{
			// give the slide a background color
			html += "style=\"background-color: " +
			        background_color.to_string().substring(0, 7) + "\">";
		}
		else
		{
			// close the tag
			html += ">";
			
			// add the background image
			html += "<img src=\"" + exporter.basename + " " + background_image +
			        "\" alt=\"Background\" width=\"" +
			        parent.width.to_string() + "\" height=\"" +
			        parent.height.to_string() + "\"/>";

			// copy the image file
			exporter.copy_file(background_image, parent.path);
		}
		
		// add tags for each Element
		foreach (var e in elements)
		{
			e.to_html(ref html, exporter, amount / elements.size);
		}
		
		html += "</div>\n";
	}
}
