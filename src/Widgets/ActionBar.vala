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

public class Widgets.ActionBar : Gtk.Grid {
    public Objects.Game game { get; construct; }

    private Gtk.Stack first_stack;
    public Gtk.SearchEntry search_entry;
    private Gtk.Popover popover = null;
    private Gtk.ListBox listbox;
    private Gtk.Revealer main_revealer;
    private Gtk.Grid snapshots_box;

    public signal void back ();
    public signal void toggle_playing (string icon_name);
    public signal void search_changed (string text);
    public signal void save_button_clicked ();
    public signal void open_last_snapshot_button_clicked ();
    public signal void popover_opened (bool value);
    public signal void snapshot_selected (Objects.Snapshot snapshot);
    public signal void reset ();

    public string visible_child_name {
        set {
            first_stack.visible_child_name = value;
        }
    }

    public bool reveal_child {
        set {
            main_revealer.reveal_child = value;
        }
    }

    public ActionBar (Objects.Game game) {
        Object (
            game: game
        );
    }

    construct {
        valign = Gtk.Align.END;
        halign = Gtk.Align.CENTER;

        var back_icon = new Gtk.Image ();
        back_icon.gicon = new ThemedIcon ("system-shutdown-symbolic");
        back_icon.pixel_size = 16;

        var back_button = new Gtk.Button ();
        back_button.can_focus = false;
        back_button.valign = Gtk.Align.CENTER;
        back_button.tooltip_text = _ ("Close Game");
        back_button.get_style_context ().add_class ("actionbar-button");
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        back_button.add (back_icon);

        var icon_play_puse = new Gtk.Image ();
        icon_play_puse.gicon = new ThemedIcon ("media-playback-pause-symbolic");
        icon_play_puse.pixel_size = 16;

        var play_button = new Gtk.Button ();
        play_button.can_focus = false;
        play_button.valign = Gtk.Align.CENTER;
        play_button.tooltip_text = _ ("Pause");
        play_button.get_style_context ().add_class ("actionbar-button");
        play_button.add (icon_play_puse);

        var reset_icon = new Gtk.Image ();
        reset_icon.gicon = new ThemedIcon ("system-reboot-symbolic");
        reset_icon.pixel_size = 16;

        var reset_button = new Gtk.Button ();
        reset_button.can_focus = false;
        reset_button.valign = Gtk.Align.CENTER;
        reset_button.tooltip_text = _ ("Reset");
        reset_button.get_style_context ().add_class ("actionbar-button");
        reset_button.add (reset_icon);

        var play_reset_box = new Gtk.Grid ();
        play_reset_box.margin_start = 24;
        play_reset_box.valign = Gtk.Align.CENTER;
        play_reset_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        play_reset_box.add (play_button);
        play_reset_box.add (reset_button);

        var save_icon = new Gtk.Image ();
        save_icon.gicon = new ThemedIcon ("document-save-symbolic");
        save_icon.pixel_size = 16;

        var save_button = new Gtk.Button ();
        save_button.margin_start = 24;
        save_button.can_focus = false;
        save_button.valign = Gtk.Align.CENTER;
        save_button.tooltip_text = _ ("Save Snapshot");
        save_button.get_style_context ().add_class ("actionbar-button");
        save_button.add (save_icon);

        var open_last_snapshot_icon = new Gtk.Image ();
        open_last_snapshot_icon.gicon = new ThemedIcon ("document-open-recent-symbolic");
        open_last_snapshot_icon.pixel_size = 16;

        var open_last_snapshot_button = new Gtk.Button ();
        open_last_snapshot_button.can_focus = false;
        open_last_snapshot_button.valign = Gtk.Align.CENTER;
        open_last_snapshot_button.tooltip_text = _ ("Open Last Snapshot");
        open_last_snapshot_button.get_style_context ().add_class ("actionbar-button");
        open_last_snapshot_button.add (open_last_snapshot_icon);

        var open_snapshots_icon = new Gtk.Image ();
        open_snapshots_icon.gicon = new ThemedIcon ("pan-down-symbolic");
        open_snapshots_icon.pixel_size = 16;

        var open_snapshots_button = new Gtk.Button ();
        open_snapshots_button.can_focus = false;
        open_snapshots_button.valign = Gtk.Align.CENTER;
        open_snapshots_button.tooltip_text = _ ("Open Snapshots");
        open_snapshots_button.get_style_context ().add_class ("actionbar-button");
        open_snapshots_button.get_style_context ().add_class ("no-padding-left-right");
        open_snapshots_button.add (open_snapshots_icon);

        snapshots_box = new Gtk.Grid ();
        snapshots_box.margin_start = 6;
        snapshots_box.valign = Gtk.Align.CENTER;
        snapshots_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        snapshots_box.add (open_last_snapshot_button);
        snapshots_box.add (open_snapshots_button);

        var fast_forward_icon = new Gtk.Image ();
        fast_forward_icon.gicon = new ThemedIcon ("preferences-system-power-symbolic");
        fast_forward_icon.pixel_size = 16; 

        var fast_forward_button = new Gtk.ToggleButton ();
        fast_forward_button.can_focus = false;
        fast_forward_button.valign = Gtk.Align.CENTER;
        fast_forward_button.tooltip_text = _ ("Fast Forward");
        fast_forward_button.get_style_context ().add_class ("actionbar-button");
        fast_forward_button.add (fast_forward_icon);

        var fullscreen_button = new Gtk.Button ();
        fullscreen_button.margin_start = 24;
        fullscreen_button.can_focus = false;
        fullscreen_button.valign = Gtk.Align.CENTER;
        fullscreen_button.tooltip_text = _ ("Play");
        fullscreen_button.get_style_context ().add_class ("actionbar-button");
        fullscreen_button.add (new Gtk.Image.from_icon_name ("view-fullscreen-symbolic", Gtk.IconSize.MENU));

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.margin = 24;
        main_box.get_style_context ().add_class ("notification");
        main_box.hexpand = true;
        main_box.pack_start (back_button, false, false, 0);
        main_box.pack_start (play_reset_box, false, false, 0);
        main_box.pack_start (save_button, false, false, 0);
        main_box.pack_start (snapshots_box, false, false, 0);
        // main_box.pack_start (fast_forward_button, false, false, 0);
        main_box.pack_start (fullscreen_button, false, false, 0);

        main_revealer = new Gtk.Revealer ();
        main_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        main_revealer.reveal_child = false;
        main_revealer.add (main_box);
        
        add (main_revealer);
        if (RetroByte.database.get_last_snapshot (game.id) == null) {
            snapshots_box.sensitive = false;
        }

        back_button.clicked.connect (() => {
            back ();
        });

        search_entry.search_changed.connect (() => {
            search_changed (search_entry.text);
        });

        save_button.clicked.connect (() => {
            save_button_clicked ();
        });

        open_last_snapshot_button.clicked.connect (() => {
            open_last_snapshot_button_clicked ();
        });

        open_snapshots_button.clicked.connect (() => {
            if (popover == null) {
                popover = new Gtk.Popover (open_snapshots_button);
                listbox = new Gtk.ListBox ();
                listbox.margin_top = 6;
                listbox.margin_bottom = 6;

                popover.add (listbox);

                popover.show.connect (() => {
                    popover_opened (true);
                });

                popover.hide.connect (() => {
                    popover_opened (false);
                });

                listbox.row_activated.connect ((row) => {
                    snapshot_selected (((Widgets.SnapshotRow) row).snapshot);
                });
            }

            foreach (unowned Gtk.Widget child in listbox.get_children ()) {
                child.destroy ();
            }

            int index = 1;
            foreach (var snapshot in RetroByte.database.get_snapshots_by_game (game.id)) {
                var row = new Widgets.SnapshotRow (snapshot, index);
                listbox.add (row);
                index++;
            }

            listbox.show_all ();
            popover.show_all ();
        });

        play_button.clicked.connect (() => {
            if (icon_play_puse.icon_name == "media-playback-start-symbolic") {
                icon_play_puse.icon_name = "media-playback-pause-symbolic";
                play_button.tooltip_text = _ ("Pause");
            } else {
                icon_play_puse.icon_name = "media-playback-start-symbolic";
                play_button.tooltip_text = _ ("Play");
            }

            toggle_playing (icon_play_puse.icon_name);
        });
        
        reset_button.clicked.connect (() => {
            reset ();
        });

        RetroByte.database.snapshot_added.connect ((snapshot) => {
            if (game.id == snapshot.game_id) {
                snapshots_box.sensitive = true;
            }
        });
    }
}

public class Widgets.SnapshotRow : Gtk.ListBoxRow {
    public Objects.Snapshot snapshot { get; construct; }
    public int index { get; construct; }

    public SnapshotRow (Objects.Snapshot snapshot, int index) {
        Object (
            snapshot: snapshot,
            index: index
        );
    }

    construct {
        var image = new Gtk.Image.from_pixbuf (
            new Gdk.Pixbuf.from_file_at_size (snapshot.get_screenshot_path (), 24, 24)
        );

        var label = new Gtk.Label ("%s %i".printf (_("Snapshot"), index));

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.add (image);
        grid.add (label);

        var button = new Gtk.ModelButton ();
        button.get_child ().destroy ();
        button.add (grid);

        add (button);

        button.clicked.connect (() => {
            activate ();
        });
    }
}
