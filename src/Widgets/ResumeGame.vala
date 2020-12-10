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

public class Widgets.ResumeGame : Gtk.EventBox {
    public Objects.Game game { get; construct; }

    private Gtk.Revealer main_revealer;
    public signal void yes_clicked ();

    public bool reveal_child {
        set {
            main_revealer.reveal_child = value;
            if (value) {
                Timeout.add (10 * 1000, () => {
                    main_revealer.reveal_child = false;
                    return GLib.Source.REMOVE;
                });
            }
        }
    }

    public ResumeGame (Objects.Game game) {
        Object (
            game: game
        );
    }

    construct {
        valign = Gtk.Align.START;
        halign = Gtk.Align.CENTER;

        var image = new Gtk.Image.from_pixbuf (
            new Gdk.Pixbuf.from_file_at_size (game.get_screenshot_path (), 64, 64)
        );

        var title_label = new Gtk.Label (_("Would you like to continue your last game?"));
        title_label.halign = Gtk.Align.START;
        title_label.get_style_context ().add_class ("font-bold");

        var subtitule_label = new Gtk.Label (_("Do you want to continue playing where you left off?"));
        subtitule_label.halign = Gtk.Align.START;

        var yes_button = new Gtk.Button.with_label (_("Yes"));
        yes_button.width_request = 64;
        yes_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        
        var no_button = new Gtk.Button.with_label (_("No"));

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.margin = 6;
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0, 1, 1);
        grid.attach (subtitule_label, 1, 1, 1, 1);

        var bar = new Gtk.Grid ();
        bar.halign = Gtk.Align.END;
        bar.margin_top = 6;
        bar.column_spacing = 6;
        bar.column_homogeneous = true;
        bar.add (no_button);
        bar.add (yes_button);

        var main_grid = new Gtk.Grid ();
        main_grid.margin_top = 48;
        main_grid.get_style_context ().add_class ("notification");
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.add (grid);
        main_grid.add (bar);

        main_revealer = new Gtk.Revealer ();
        main_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        main_revealer.add (main_grid);
        
        add (main_revealer);

        no_button.clicked.connect (() => {
            reveal_child = false;
        });

        yes_button.clicked.connect (() => {
            yes_clicked ();
        });
    }
}