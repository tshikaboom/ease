/*
Copyright 2010 Nate Stedman. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of
conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list
of conditions and the following disclaimer in the documentation and/or other materials
provided with the distribution.

THIS SOFTWARE IS PROVIDED BY NATE STEDMAN ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NATE STEDMAN OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
 * An individual item in a {@link Source.Group}.
 *
 * Source.Item contains a Gtk.Button, which in turn contains an image and a
 * label. When added to a {@link Source.Group}, signals are automatically set
 * up to manage the {@link Source.View} this item is a part of.
 */
public class Source.Item : Gtk.HBox
{
	/**
	 * The Source.Item's image widget, displayed on the left.
	 */
	private Gtk.Image image;
	
	/**
	 * The Source.Item's label widget, displayed to the right of the image.
	 */
	private Gtk.Label label;
	
	/**
	 * The right label widget, which can display a number if desired.
	 */
	private Gtk.Label right_label;
	
	/**
	 * The alignment for the right label.
	 */
	private Gtk.Alignment right_align;
	
	/**
	 * A number, displayed on the righthand side of the Source.Item. If
	 * notification is 0, the label is not displayed.
	 */
	public int notification
	{
		get { return notification_priv; }
		set
		{
			if (value == notification_priv) return;
			
			// if value is 0, notification_priv can't be
			if (value == 0)
			{
				// therefore, the widget has been added, so remove it
				right_align.remove(right_label);
			}
			
			// update the label
			right_label.label = (selected ?
			                     FORMAT_RIGHT_OLD : 
			                     FORMAT_RIGHT_NEW).printf(value);
			
			// if necessary, add the label
			if (notification_priv == 0)
			{
				right_align.add(right_label);
			}
			
			// store the value
			notification_priv = value;
		}
	}
	
	/**
	 * Private store for notification value
	 */
	private int notification_priv = 0;
	
	/**
	 * The Source.Item's button widget, containing the image and label.
	 */
	private Gtk.Button button;
	
	/**
	 * The widget this Source.Item is linked with in its {@link Source.View}.
	 */
	public Gtk.Widget widget;
	
	/**
	 * The text displayed in the label widget.
	 */
	private string label_text;
	
	/**
	 * The size of lefthand side icons.
	 */
	public const Gtk.IconSize ICON_SIZE = Gtk.IconSize.MENU;
	
	/**
	 * The padding of the internal button elements.
	 */
	private const int HBOX_PADDING = 2;
	
	/**
	 * Format string for selected items.
	 */
	private const string FORMAT_SELECTED = "<b>%s</b>";
	
	/**
	 * Format string for deselected items.
	 */
	private const string FORMAT_DESELECTED = "%s";
	
	/**
	 * Format string for right notification number when new.
	 */
	private const string FORMAT_RIGHT_NEW = "<small><b>%i</b></small>";
	
	/**
	 * Format string for right notification number once viewed.
	 */
	private const string FORMAT_RIGHT_OLD = "<small><b>%i</b></small>";
	
	/**
	 * Padding to the sides of the label and image. Not used on the right of
	 * the image, as the label left padding covers this space.
	 */
	private const int ITEM_PADDING = 5;
	
	/**
	 * Alignment of label.
	 */
	private const float LABEL_VERT_ALIGN = 0.6f;
	
	/**
	 * Relief style for selected items.
	 */
	private const Gtk.ReliefStyle RELIEF_SELECTED = Gtk.ReliefStyle.NORMAL;
	
	/**
	 * Relief style for deselected items.
	 */
	private const Gtk.ReliefStyle RELIEF_DESELECTED = Gtk.ReliefStyle.NONE;
	
	/**
	 * If this Source.Item is the selected item in its {@link Source.List}.
	 */
	public bool selected
	{
		get { return button.relief == RELIEF_SELECTED; }
		set
		{
			// don't emit any signals or change anything if it's redundant
			if (selected == value) return;
			
			// otherwise, go ahead
			button.relief = value ? RELIEF_SELECTED : RELIEF_DESELECTED;
			label.label = (value ?
			               FORMAT_SELECTED :
			               FORMAT_DESELECTED).printf(label_text);
			
			// if "selected" is being set to true, emit a signal
			if (value)
			{
				clicked(this);
				
				// remove bold from notification text
				right_label.label = FORMAT_RIGHT_OLD.printf(notification);
			}
		}
	}
	
	/**
	 * Emitted when the Source.Item's Gtk.Button is clicked. Generally used
	 * internally to change {@link Source.List} selection.
	 *
	 * @param sender The Source.Item that emitted the signal (generally, "this").
	 */
	public signal void clicked(Source.Item sender);
	
	/**
	 * Creates a Source.Item with a customizable icon and text.
	 *
	 * @param text The text to display in the source item.
	 * @param img The image widget to use (note that this icon should use
	 * the Gtk.IconSize constant ICON_SIZE to fit in with other items).
	 * @param widg The widget that this Source.Item should be linked with.
	 * If null, this Source.Item will only emit the clicked signal when 
	 * clicked, without any automatic UI changes.
	 */
	public Item(string text, Gtk.Image img, Gtk.Widget? widg)
	{
		// set properties
		homogeneous = false;
		label_text = text;
		widget = widg;
		
		// build subwidgets
		image = img;
		label = new Gtk.Label(FORMAT_DESELECTED.printf(text));
		label.use_markup = true;
		button = new Gtk.Button();
		button.can_focus = false;
		selected = false;
		var label_align = new Gtk.Alignment(0, LABEL_VERT_ALIGN, 0, 0);
		label_align.set_padding(0, 0, ITEM_PADDING, ITEM_PADDING);
		right_label = new Gtk.Label("");
		right_label.use_markup = true;
		right_align = new Gtk.Alignment(1, LABEL_VERT_ALIGN, 1, 1);
		var image_align = new Gtk.Alignment(0.5f, 0.5f, 0, 1);
		image_align.set_padding(0, 0, ITEM_PADDING, 0);
		
		// build the source item
		label_align.add(label);
		image_align.add(image);
		var hbox = new Gtk.HBox(false, HBOX_PADDING);
		hbox.pack_start(image_align, false, false, 0);
		hbox.pack_start(label_align, true, true, 0);
		button.add(hbox);
		
		pack_start(button, false, false, 0);
		pack_start(new Gtk.Alignment(1, 1, 0, 0), true, true, 0);
		pack_end(right_align, false, false, 0);
		
		// send the clicked signal when the button is clicked
		button.clicked.connect(() => {
			if (!selected)
			{
				clicked(this);
			}
		});
	}
	
	/**
	 * Creates a Source.Item with a stock icon and customizable text.
	 *
	 * @param text The text to display in the source item.
	 * @param item The stock item to take the icon from.
	 * @param widg The widget that this Source.Item should be linked with.
	 * If null, this Source.Item will only emit the clicked signal when 
	 * clicked, without any automatic UI changes.
	 */
	public Item.from_stock_icon(string text, string item, Gtk.Widget? widg)
	{
		this(text, new Gtk.Image.from_stock(item, ICON_SIZE), widg);
	}
	
	/**
	 * Creates a Source.Item with a stock icon and customizable text.
	 *
	 * @param text The text to display in the source item.
	 * @param item The stock item to take the label from.
	 * @param img The image widget to use (note that this icon should use
	 * the Gtk.IconSize constant ICON_SIZE to fit in with other items).
	 * @param widg The widget that this Source.Item should be linked with.
	 * If null, this Source.Item will only emit the clicked signal when 
	 * clicked, without any automatic UI changes.
	 */
	public Item.from_stock_text(string item, Gtk.Image img, Gtk.Widget? widg)
	{
		Gtk.StockItem stock = Gtk.StockItem();
		if (Gtk.stock_lookup(item, stock))
		{
			this(stock.label.replace("_", ""), img, widg);
		}
	}
	
	/**
	 * Creates a Source.Item with a stock icon and text.
	 *
	 * @param item The stock item to take the icon and text from.
	 * @param widg The widget that this Source.Item should be linked with.
	 * If null, this Source.Item will only emit the clicked signal when 
	 * clicked, without any automatic UI changes.
	 */
	public Item.from_stock(string item, Gtk.Widget? widg)
	{
		Gtk.StockItem stock = Gtk.StockItem();
		if (Gtk.stock_lookup(item, stock))
		{
			this(stock.label.replace("_", ""),
			     new Gtk.Image.from_stock(item, ICON_SIZE),
			     widg);
		}
	}
	
	/**
	 * Selects this Source.Item, emitting a "clicked" signal.
	 */
	public void select()
	{
		selected = true;
	}
}

