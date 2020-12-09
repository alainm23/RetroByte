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

    private Gtk.TreeView view;
    private Gtk.ListStore listmodel;
    private Gtk.TreeModelFilter modelfilter;
    private Gtk.TreeModelSort modelsort;
    enum columns { OBJECT, NAME, DEVELOPER, GENRE, FAVORITE }

    public signal void game_selected (Objects.Game game);

    construct {
        var platform_label = new Gtk.Label (null);
        platform_label.get_style_context ().add_class ("h1");
        platform_label.get_style_context ().add_class ("font-bold");

        var platform_size_label = new Gtk.Label ("10");
        platform_size_label.valign = Gtk.Align.START;
        platform_size_label.margin_top = 6;
        platform_size_label.get_style_context ().add_class ("font-bold");
        platform_size_label.get_style_context ().add_class ("h3");
        platform_size_label.get_style_context ().add_class ("font-primary");

        var platform_box = new Gtk.Grid ();
        platform_box.column_spacing = 6;
        platform_box.margin = 32;
        platform_box.halign = Gtk.Align.CENTER;
        platform_box.add (platform_label);
        platform_box.add (platform_size_label);

        listbox = new Gtk.ListBox ();
        listmodel = new Gtk.ListStore (
            5,
            typeof (Objects.Game),
            typeof (string),
            typeof (string),
            typeof (string),
            typeof (string)
        );
        
        view = new Gtk.TreeView ();
        view.activate_on_single_click = true;

        view.row_activated.connect ((path, column) => {
            game_selected (get_game_by_path (path));
        });

        // view.button_press_event.connect (show_context_menu);

        view.insert_column_with_attributes (-1, "object", new Gtk.CellRendererText ());

        var cell = new Gtk.CellRendererText ();
        cell.ellipsize = Pango.EllipsizeMode.END;
        cell.ellipsize_set = true;
        cell.stretch = Pango.Stretch.ULTRA_EXPANDED;
        cell.stretch_set = true;
        view.insert_column_with_attributes (-1, _ ("Name"), cell, "text", columns.NAME);

        cell = new Gtk.CellRendererText ();
        cell.ellipsize = Pango.EllipsizeMode.END;
        cell.ellipsize_set = true;
        cell.stretch = Pango.Stretch.ULTRA_EXPANDED;
        cell.stretch_set = true;
        view.insert_column_with_attributes (-1, _ ("Developer"), cell, "text", columns.DEVELOPER);

        cell = new Gtk.CellRendererText ();
        cell.ellipsize = Pango.EllipsizeMode.END;
        cell.ellipsize_set = true;
        cell.stretch = Pango.Stretch.EXPANDED;
        cell.stretch_set = true;
        view.insert_column_with_attributes (-1, _ ("Genre"), cell, "text", columns.GENRE);
        
        cell = new Gtk.CellRendererText ();
        cell.ellipsize = Pango.EllipsizeMode.END;
        cell.ellipsize_set = true;
        cell.stretch = Pango.Stretch.EXPANDED;
        cell.stretch_set = true;
        view.insert_column_with_attributes (-1, _ ("Favorite"), cell, "text", columns.FAVORITE);

        setup_columns ();

        var listbox_scrolled = new Gtk.ScrolledWindow (null, null);
        listbox_scrolled.expand = true;
        listbox_scrolled.add (view);

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        // grid.add (platform_box);
        grid.add (listbox_scrolled);

        add (grid);

        notify["platform"].connect (() => {
            listmodel.clear ();
            platform_label.label = _("Nintendo 64");

            modelfilter = new Gtk.TreeModelFilter (listmodel, null);
            // modelfilter.set_visible_func (tracks_filter_func);

            modelsort = new Gtk.TreeModelSort.with_model (modelfilter);
            view.set_model (modelsort);

            //  foreach (unowned Gtk.Widget child in listbox.get_children ()) {
            //      child.destroy ();
            //  }

            add_games ();
            show_all ();
        });

        //  listbox.row_activated.connect ((child) => {
        //      var game = ((Widgets.GameRow) child).game;
        //      game_selected (game);
        //  });

        RetroByte.database.game_added.connect ((game) => {
            if (game.platform == platform) {
                var row = new Widgets.GameRow (game);
                listbox.add (row);
                listbox.show_all ();
            }
        });
    }
    
    private Objects.Game? get_game_by_path (Gtk.TreePath path) {
        Value val;
        Gtk.TreeIter iter;
        modelsort.get_iter (out iter, path);
        modelsort.get_value (iter, 0, out val);
        return val.get_object () as Objects.Game;
    }

    private void setup_columns () {
        var col = view.get_column (columns.OBJECT);
        col.visible = false;

        col = view.get_column (columns.NAME);
        col.expand = true;
        col.resizable = true;

        col = view.get_column (columns.DEVELOPER);
        col.resizable = true;

        col = view.get_column (columns.GENRE);
        col.resizable = true;

        col = view.get_column (columns.FAVORITE);
        col.resizable = false;

        setup_column_sort ();
    }

    private void setup_column_sort () {
        view.get_column (columns.NAME).sort_column_id = columns.NAME;
        view.get_column (columns.DEVELOPER).sort_column_id = columns.DEVELOPER;
        view.get_column (columns.GENRE).sort_column_id = columns.GENRE;
        view.get_column (columns.FAVORITE).sort_column_id = columns.FAVORITE;
    }

    private void add_games () {
        foreach (var game in RetroByte.database.get_games_by_platform (platform)) {
            add_game (game);
        }

        listbox.show_all ();
    }

    public void add_game (Objects.Game game) {
        Gtk.TreeIter iter;
        listmodel.append (out iter);
        listmodel.set (iter, 
            columns.OBJECT, game,
            columns.NAME, game.name,
            columns.DEVELOPER, "",
            columns.GENRE, "",
            columns.FAVORITE, ""
        );
    }

    public void search_changed (string text) {
        //  listbox.set_filter_func ((child) => {
        //      var game = ((Widgets.GameRow) child).game;
        //      return text.down () in game.name.down ();
        //  });
    }
}