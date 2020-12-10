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

public class Objects.Game : GLib.Object {
    public int id { get; set; default = 0;}
    public int is_favorite { get; set; default = 0;}
    public string name { get; set; default = ""; }
    public string platform { get; set; default = ""; }
    public string uri { get; set; default = ""; }
    public string date_added { get; set; default = new GLib.DateTime.now_local ().to_string (); }
    public string last_played { get; set; default = ""; }

    private string _path;
	public string path {
		get {
			_path = "%s/%i".printf (RetroByte.utils.SNAPSHOTS_FOLDER, id);
			return _path;
		}

		set {
			_path = value;
		}
	}

    public string get_snapshot_path () {
		return Path.build_filename (path, "snapshot");
	}

	public string get_screenshot_path () {
		return Path.build_filename (path, "screenshot");
    }
    
    public string get_save_ram_path () {
		return Path.build_filename (path, "save");
    }

    public void save_memory (Retro.Core core, Retro.CoreView core_view) {
        RetroByte.utils.create_dir_with_parents ("/com.github.alainm23.retro-byte/snapshots/" + id.to_string ());

        core.save_state (Path.build_filename (path, "snapshot"));

		core_view.get_pixbuf ().save (
			Path.build_filename (path, "screenshot"), "jpeg", "quality", "100"
        );
        
        if (core.get_memory_size (Retro.MemoryType.SAVE_RAM) > 0) {
            core.save_memory (Retro.MemoryType.SAVE_RAM, get_save_ram_path ());
        }
    }
}