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

public class Views.CoreView : Gtk.Grid {
    public Objects.Game game { get; construct; }
    public Retro.Core core;
    public Retro.CoreView core_view;
    public Retro.CoreDescriptor core_descriptor;
    
    private Services.SnapshotManager snapshot_manager;
    private Widgets.HeaderBar headerbar;
    private string tmp_save_dir;

    public signal void back ();

    public CoreView (Objects.Game game) {
        Object (
            game: game
        );
    }

    construct {
        core_descriptor = RetroByte.core_manager.get_core_for_id (game.platform);
        // snapshot_manager = new Services.SnapshotManager (game, core_descriptor.get_id ());

        orientation = Gtk.Orientation.VERTICAL;
        headerbar = new Widgets.HeaderBar ();
        headerbar.title = game.name;
        
        var revealer = new Gtk.Revealer ();
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        revealer.reveal_child = true;
        revealer.add (headerbar);

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
		core.save_directory = tmp_save_dir;

        core.set_medias ({
            game.uri
        });

        core_view = new Retro.CoreView ();
        core_view.expand = true;
        core_view.set_core (core);
        core_view.set_as_default_controller (core);

        core.boot ();
        core.run ();

        add (revealer);
        add (core_view);
 
        show_all ();

        headerbar.back.connect (() => {
            back ();
        });

        headerbar.toggle_playing.connect ((icon_name) => {
            toggle_playing (icon_name);
        });

        headerbar.save_button_clicked.connect (() => {
            // snapshot_manager.create_snapshot (is_automatic, save_to_snapshot);
        });
    }

    //  protected virtual void save_to_snapshot (Objects.Snapshot snapshot) throws Error {
	//  	if (core.get_memory_size (Retro.MemoryType.SAVE_RAM) > 0)
	//  		core.save_memory (Retro.MemoryType.SAVE_RAM,
	//  		                  snapshot.get_save_ram_path ());

	//  	var tmp_dir = File.new_for_path (tmp_save_dir);
	//  	var dest_dir = File.new_for_path (snapshot.get_save_directory_path ());
	//  	FileOperations.copy_contents (tmp_dir, dest_dir);

	//  	if (media_set.get_size () > 1)
	//  		snapshot.set_media_data (media_set);

	//  	core.save_state (snapshot.get_snapshot_path ());
	//  	save_screenshot (snapshot.get_screenshot_path ());
	//  	snapshot.screenshot_aspect_ratio = Retro.pixbuf_get_aspect_ratio (current_state_pixbuf);
    //  }
    
    private string create_tmp_save_dir () throws Error {
		return DirUtils.make_tmp ("games_save_dir_XXXXXX");
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