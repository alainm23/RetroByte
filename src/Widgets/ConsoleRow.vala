/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Widgets.ConsoleRow : Gtk.ListBoxRow {
    public Gtk.Image image;

    public string icon_name { get; construct; }
    public string title { get; construct; }

    public ConsoleRow (string title, string icon_name) {
        Object (
            title: title,
            icon_name: icon_name
        );
    }

    construct {
        get_style_context ().add_class ("pane-row");

        image = new Gtk.Image ();
        image.halign = Gtk.Align.CENTER;
        image.valign = Gtk.Align.CENTER;
        image.gicon = new ThemedIcon (icon_name);
        image.pixel_size = 16;

        var title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class ("font-weight-600");
        title_label.use_markup = true;

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.margin = 6;
        main_box.pack_start (image, false, false, 0);
        main_box.pack_start (title_label, false, false, 6);

        add (main_box);
    }
}