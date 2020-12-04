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

public class Widgets.Pane : Gtk.EventBox {
    private Gtk.ListBox listbox;

    public signal void row_selected (string platform);

    construct {
        var row1 = new Widgets.ActionRow (_("Recently Played"), "folder-recent-symbolic");
        row1.image.get_style_context ().add_class ("recently-icon");

        var row2 = new Widgets.ActionRow (_("Favorites"), "help-about-symbolic");
        row2.image.get_style_context ().add_class ("favorite-icon");

        var row3 = new Widgets.ActionRow (_("Save States"), "document-save-as-symbolic");
        row3.image.get_style_context ().add_class ("states-icon");

        var gba_row = new Widgets.ConsoleRow (_("Game Boy Advance"), "gba-symbolic");
        gba_row.image.get_style_context ().add_class ("rom-icon");
        gba_row.margin_top = 6;

        var snes_row = new Widgets.ConsoleRow (_("Super Nintendo (SNES)"), "gba-symbolic");
        snes_row.image.get_style_context ().add_class ("rom-icon");

        var psx_row = new Widgets.ConsoleRow (_("Nintendo 64"), "gba-symbolic");
        psx_row.image.get_style_context ().add_class ("rom-icon");

        listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        listbox.expand = true;
        listbox.get_style_context ().add_class ("sidebar-header");
        listbox.add (row1);
        listbox.add (row2);
        listbox.add (row3);
        listbox.add (gba_row);
        listbox.add (snes_row);
        listbox.add (psx_row);
        listbox.show_all ();

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_button.valign = Gtk.Align.CENTER;
        add_button.halign = Gtk.Align.START;
        add_button.always_show_image = true;
        add_button.can_focus = false;
        add_button.label = _("Add Games");
        add_button.margin_top = add_button.margin_bottom = 3;
        add_button.get_style_context ().add_class ("flat");
        add_button.get_style_context ().add_class ("font-weight-700");

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        action_bar.pack_start (add_button);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.expand = true;
        box.pack_start (listbox, true, true, 0);
        box.pack_end (action_bar, false, false, 0);

        add (box);

        listbox.row_selected.connect ((row) => {
            if (row.get_index () == 0) {

            } else if (row.get_index () == 1) {

            } else if (row.get_index () == 2) {

            } else if (row.get_index () == 3) {
                row_selected ("mgba.libretro");
            } else if (row.get_index () == 4) {
                row_selected ("bsnes_mercury_balanced.libretro");
            } else if (row.get_index () == 5) {
                row_selected ("parallel_n64.libretro");
            }
        });

        add_button.clicked.connect (() => {
            var chooser = new Gtk.FileChooserDialog (
                _("Select game files"), RetroByte.instance.main_window, Gtk.FileChooserAction.OPEN,
                _("_Cancel"), Gtk.ResponseType.CANCEL,
                _("_Add"), Gtk.ResponseType.ACCEPT);
    
    
            chooser.select_multiple = true;
    
            var filter = new Gtk.FileFilter ();
            chooser.filter = filter;
            filter.add_mime_type ("application/x-gba-rom");
            filter.add_mime_type ("application/vnd.nintendo.snes.rom"); 
            filter.add_mime_type ("application/x-n64-rom");               
    
            if (chooser.run () == Gtk.ResponseType.ACCEPT)
                foreach (var uri in chooser.get_uris ()) {
                    var file = File.new_for_uri (uri);
                    try {
                        var file_info = file.query_info ("standard::*", GLib.FileQueryInfoFlags.NONE);
                        var system_type = RetroByte.utils.get_system_type (file_info.get_content_type ());

                        if (system_type != null) {
                            var game = new Objects.Game ();
                            game.name = file_info.get_name ();
                            game.uri = uri;
                            game.platform = system_type;
    
                            RetroByte.database.insert_game (game);
                        }
                    } catch (Error err) {
                        warning (err.message);
                    }
    
                    file.dispose ();
                }
    
            chooser.close ();
        });
    }
}