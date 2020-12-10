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

    private Gdk.Window window_gdk;
    private Gdk.Cursor arrow_cursor;
    private Gdk.Cursor blank_cursor;

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
        blank_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.BLANK_CURSOR);
        arrow_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.ARROW);
        window_gdk = RetroByte.instance.main_window.get_window ();

        var save_memory = game.get_save_ram_path ();

        //  tmp_save_dir = create_tmp_save_dir ();
        //  if (snapshot != null) {
        //      snapshot.copy_save_dir_to (tmp_save_dir);
        //  }

        prepare_core ();
        load_save_ram (save_memory);
    }

    private void prepare_core () throws Error {
        core_descriptor = RetroByte.core_manager.get_core_for_id (game.platform);
        actionbar = new Widgets.ActionBar (game);
        var resume_widget = new Widgets.ResumeGame (game);
        var headerbar = new Hdy.HeaderBar ();

        headerbar.show_close_button = true;
        headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.title = game.name;

        string module_path = core_descriptor.get_module_file ().get_path ();
        core = new Retro.Core (module_path);
        
        core.system_directory = GLib.Path.build_filename (RetroByte.utils.CORES_FOLDER, core_descriptor.get_id ());
        core.save_directory = tmp_save_dir;

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

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (headerbar);
        grid.add (core_view);

        var overlay = new Gtk.Overlay ();
        overlay.add (grid);
        overlay.add_overlay (actionbar);
        overlay.add_overlay (resume_widget);
        
        add_events (Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        add (overlay);
        show_all ();

        core.boot ();
        core.run ();

        Timeout.add (1500, () => {
            if (FileUtils.test (game.get_snapshot_path (), FileTest.EXISTS)) {
                resume_widget.reveal_child = true;
            }

            return GLib.Source.REMOVE;
        });

        resume_widget.yes_clicked.connect (() => {
            resume_widget.reveal_child = false;
            core.load_state (game.get_snapshot_path ());
        });

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

            snapshot.save_state (core, core_view);
        });

        actionbar.open_last_snapshot_button_clicked.connect (() => {
            var last_snapshot = RetroByte.database.get_last_snapshot (game.id);

            if (last_snapshot != null) {
                core.load_state (last_snapshot.get_snapshot_path ());
                load_save_ram (last_snapshot.get_save_ram_path ());
            }
        });

        event.connect (actionbar_revealer);
    }

    //  protected virtual void reset_with_snapshot (Objects.Snapshot? last_snapshot) throws Error {
	//  	if (last_snapshot == null) {
    //          return;
    //      }

	//  	load_save_ram (last_snapshot.get_save_ram_path ());

	//  	if (last_snapshot.has_media_data ()) {
    //          media_set.selected_media_number = last_snapshot.get_media_data ();
    //      }
    //  }

    private void load_save_ram (string save_ram_path) throws Error {
		if (!FileUtils.test (save_ram_path, FileTest.EXISTS)) {
            return;
        }
			
		if (core.get_memory_size (Retro.MemoryType.SAVE_RAM) == 0) {
            return;
        }

		core.load_memory (Retro.MemoryType.SAVE_RAM, save_ram_path);
	}

    public void preview_snapshot (Objects.Snapshot snapshot) {
		var screenshot_path = snapshot.get_screenshot_path ();
		Gdk.Pixbuf pixbuf = null;

		// Treat errors locally because loading the snapshot screenshot is not
		// a critical operation
		try {
			pixbuf = new Gdk.Pixbuf.from_file (screenshot_path);
			//  var aspect_ratio = snapshot.screenshot_aspect_ratio;

			//  if (aspect_ratio != 0)
			//  	Retro.pixbuf_set_aspect_ratio (pixbuf, (float) aspect_ratio);
		}
		catch (Error e) {
			warning ("Couldn't load %s: %s", screenshot_path, e.message);
		}

		core_view.set_pixbuf (pixbuf);
    }
    
    private bool actionbar_revealer (Gdk.Event event) {
        if (event.type == Gdk.EventType.MOTION_NOTIFY) {
            if (timeout_id != 0) {
                Source.remove (timeout_id);
            }
            
            // window_gdk.set_cursor (arrow_cursor);
            actionbar.reveal_child = true;
            timeout_id = Timeout.add (3000, () => {
                timeout_id = 0;

                if (popover_opened == false) {
                    // window_gdk.set_cursor (blank_cursor);
                    actionbar.reveal_child = false;
                }

                return GLib.Source.REMOVE;
            });
        }

        return true;
    }

    private string create_tmp_save_dir () throws Error {
		return DirUtils.make_tmp ("games_save_dir_XXXXXX");
    }

    public void stop () {
        window_gdk.set_cursor (arrow_cursor);
        event.disconnect (actionbar_revealer);
        game.save_memory (core, core_view);

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