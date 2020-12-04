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

public class Widgets.GameRow : Gtk.ListBoxRow {
    public Objects.Game game { get; construct; }

    public GameRow (Objects.Game game) {
        Object (
            game: game
        );
    }

    construct {
        // get_style_context ().add_class ("game-child");
        valign = Gtk.Align.START;

        // var pixbuf = new Gdk.Pixbuf.from_file_at_scale ("/home/alain/3378c08fb31adb1be9581ca3a40e72e7.jpg", 100, 76, true);
        // var cover = new Gtk.Image.from_pixbuf (pixbuf);

        var title = new Gtk.Label (game.name);
        title.wrap = true;
        // title.justify = Gtk.Justification.CENTER;
        title.get_style_context ().add_class ("font-weight-600");

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.add (title);

        add (grid);
    }
}