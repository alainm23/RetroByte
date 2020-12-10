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

    public static void copy_contents (File src, File dest) throws Error {
      copy_recursively (src, dest, true);
    }

    private static void copy_recursively (File src, File dest, bool merge_flag) throws Error {
        var src_type = src.query_file_type (FileQueryInfoFlags.NONE);
    
        if (src_type == FileType.DIRECTORY) {
          if (!dest.query_exists () || !merge_flag) {
            dest.make_directory ();
            src.copy_attributes (dest, FileCopyFlags.NONE);
          }
    
          var src_path = src.get_path ();
          var dest_path = dest.get_path ();
          var enumerator = src.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
    
          for (var info = enumerator.next_file (); info != null; info = enumerator.next_file ()) {
            // src_object is any file found in the src directory (could be
            // a file or another directory)
            var info_name = info.get_name ();
            var src_object_path = Path.build_filename (src_path, info_name);
            var src_object = File.new_for_path (src_object_path);
            var dest_object_path = Path.build_filename (dest_path, info_name);
            var dest_object = File.new_for_path (dest_object_path);
    
            copy_recursively (src_object, dest_object, merge_flag);
          }
        } else if (src_type == FileType.REGULAR) {
          src.copy (dest, FileCopyFlags.NONE);
        }
    }
}
