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

public class Views.Platform : Gtk.EventBox {
    public string platform { get; set; }

    private Gtk.ListBox listbox;
    public signal void game_selected (Objects.Game game);

    construct {
        listbox = new Gtk.ListBox ();

        var listbox_scrolled = new Gtk.ScrolledWindow (null, null);
        listbox_scrolled.expand = true;
        listbox_scrolled.add (listbox);

        add (listbox_scrolled);

        notify["platform"].connect (() => {
            foreach (unowned Gtk.Widget child in listbox.get_children ()) {
                child.destroy ();
            }

            add_games ();
            show_all ();
        });

        listbox.row_activated.connect ((child) => {
            var game = ((Widgets.GameRow) child).game;
            game_selected (game);
        });

        RetroByte.database.game_added.connect ((game) => {
            if (game.platform == platform) {
                var row = new Widgets.GameRow (game);
                listbox.add (row);
                listbox.show_all ();
            }
        });
    }

    private void add_games () {
        foreach (var game in RetroByte.database.get_games_by_platform (platform)) {
            var row = new Widgets.GameRow (game);
            listbox.add (row);
        }

        listbox.show_all ();
    }

    public void search_changed (string text) {
        listbox.set_filter_func ((child) => {
            var game = ((Widgets.GameRow) child).game;
            return text.down () in game.name.down ();
        });
    }
}