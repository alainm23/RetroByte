// vala-lint=skip-file

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

public class Utils : GLib.Object {
    public string APP_FOLDER; // vala-lint=naming-convention
    public string SNAPSHOTS_FOLDER; // vala-lint=naming-convention
    public string CORES_FOLDER;

    private Gee.HashMap<string, string> systems;

    construct {
        APP_FOLDER = GLib.Path.build_filename (Environment.get_user_data_dir (), "com.github.alainm23.retro-byte");
        SNAPSHOTS_FOLDER = GLib.Path.build_filename (APP_FOLDER, "snapshots");
        CORES_FOLDER = GLib.Path.build_filename (APP_FOLDER, "cores");

        systems = new Gee.HashMap<string, string> ();
        systems.set ("application/vnd.nintendo.snes.rom", "bsnes_mercury_balanced.libretro");
        systems.set ("application/x-gba-rom", "mgba.libretro");
        systems.set ("application/x-n64-rom", "parallel_n64.libretro");
    }

    public void create_dir_with_parents (string dir) {
        string path = Environment.get_user_data_dir () + dir;
        File tmp = File.new_for_path (path);
        if (tmp.query_file_type (0) != FileType.DIRECTORY) {
            GLib.DirUtils.create_with_parents (path, 0775);
        }
    }

    public string? get_system_type (string mime_type) {
        return systems.get (mime_type);
    }
    
    public static string get_config_dir () {
		var config_dir = Environment.get_user_config_dir ();
		return @"$config_dir/games";
    }
    
    public string get_platforms_dir () {
		var config_dir = get_config_dir ();
		return @"$config_dir/platforms";
    }

    public static string get_data_dir () {
		var data_dir = Environment.get_user_data_dir ();
		return @"$data_dir/games";
	}
}
