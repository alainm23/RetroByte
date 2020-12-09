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

public class Views.CoreView : Gtk.EventBox {
    public Objects.Game game { get; construct; }
    public Retro.Core core;
    public Retro.CoreView core_view;
    public Retro.CoreDescriptor core_descriptor;
    
    private Services.SnapshotManager snapshot_manager;
    private Widgets.ActionBar actionbar;
    private string tmp_save_dir;
    private uint timeout_id = 0;
    private bool popover_opened = false;

    public signal void back ();

    public CoreView (Objects.Game game) {
        Object (
            game: game
        );
    }

    construct {
        //  var blank_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.BLANK_CURSOR);
        //  var arrow_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.ARROW);
        //  var window_gdk = get_window ();

        core_descriptor = RetroByte.core_manager.get_core_for_id (game.platform);
        actionbar = new Widgets.ActionBar (game);

        var headerbar = new Hdy.HeaderBar ();
        headerbar.show_close_button = true;
        headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.title = game.name;
        
        var revealer = new Gtk.Revealer ();
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        revealer.valign = Gtk.Align.END;
        revealer.halign = Gtk.Align.CENTER;
        revealer.reveal_child = true;
        revealer.add (actionbar);

        string module_path;
		if (core_descriptor != null) {
			var module_file = core_descriptor.get_module_file ();
			if (module_file == null) {
                // throw new RetroError.MODULE_NOT_FOUND ("No module found for “%s”.", core_descriptor.get_name ());
            }

			module_path = module_file.get_path ();
		} else {
            // module_path = core_source.get_module_path ();
        }

        core = new Retro.Core (module_path);
        
        tmp_save_dir = create_tmp_save_dir ();
        core.system_directory = GLib.Path.build_filename (RetroByte.utils.CORES_FOLDER, core_descriptor.get_id ());
        core.save_directory = tmp_save_dir;
        print ("tmp_save_dir: %s\n".printf (tmp_save_dir));

        core.set_medias ({
            game.uri
        });

        core.log.connect (Retro.g_log);
        core.shutdown.connect (stop);
		core.crashed.connect ((core, error) => {
			// is_error = true;
			// game.update_last_played ();
			// crash (error);
		});

        core_view = new Retro.CoreView ();
        core_view.expand = true;
        core_view.set_core (core);
        core_view.set_as_default_controller (core);

        core.boot ();
        core.run ();

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (headerbar);
        grid.add (core_view);

        var overlay = new Gtk.Overlay ();
        overlay.add (grid);
        overlay.add_overlay (revealer);

        add_events (Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        add (overlay);
        show_all ();

        actionbar.back.connect (() => {
            back ();
        });

        actionbar.toggle_playing.connect ((icon_name) => {
            toggle_playing (icon_name);
        });

        actionbar.popover_opened.connect ((value) => {
            popover_opened = value;
        });

        actionbar.snapshot_selected.connect ((snapshot) => {
            core.load_state (snapshot.get_snapshot_path ());
            load_save_ram (snapshot.get_save_ram_path ());
        });

        actionbar.reset.connect (() => {
            core.reset ();
        });

        actionbar.save_button_clicked.connect (() => {
            var snapshot = new Objects.Snapshot ();
            snapshot.game_id = game.id;
            snapshot.id = RetroByte.database.insert_snapshot (snapshot);
            snapshot.update_path ();

            snapshot.save_state (core, core_view);
        });

        actionbar.open_last_scene_button_clicked.connect (() => {
            var last_snapshot = RetroByte.database.get_last_snapshot (game.id);
            last_snapshot.update_path ();

            if (last_snapshot != null) {
                core.load_state (last_snapshot.get_snapshot_path ());
                load_save_ram (last_snapshot.get_save_ram_path ());
            }
        });

        event.connect ((event) => {
            if (event.type == Gdk.EventType.MOTION_NOTIFY) {
                if (timeout_id != 0) {
                    Source.remove (timeout_id);
                }
                
                revealer.reveal_child = true;
                timeout_id = Timeout.add (3000, () => {
                    timeout_id = 0;

                    if (popover_opened == false) {
                        revealer.reveal_child = false;
                    }

                    return GLib.Source.REMOVE;
                });
            }
        });


    }

    private string create_tmp_save_dir () throws Error {
		return DirUtils.make_tmp ("games_save_dir_XXXXXX");
    }
    
    //  private void load_from_snapshot (Objects.Snapshot snapshot) {
    //      tmp_save_dir = create_tmp_save_dir ();
	//  	snapshot.copy_save_dir_to (tmp_save_dir);
	//  	core.save_directory = tmp_save_dir;

	//  	load_save_ram (snapshot.get_save_ram_path ());
	//  	core.load_state (snapshot.get_snapshot_path ());

	//  	if (snapshot.has_media_data ()) {
    //          media_set.selected_media_number = snapshot.get_media_data ();
    //      }
    //  }

    private void load_save_ram (string save_ram_path) throws Error {
		if (!FileUtils.test (save_ram_path, FileTest.EXISTS))
			return;

		if (core.get_memory_size (Retro.MemoryType.SAVE_RAM) == 0)
			return;

		core.load_memory (Retro.MemoryType.SAVE_RAM, save_ram_path);
	}

    public void stop () {
        core.stop ();
        core_view.set_core (null);
    }

    public void toggle_playing (string icon_name) {
        if (icon_name == "media-playback-start-symbolic") {
            core.stop ();
        } else {
            core.run ();
        }
    }
}