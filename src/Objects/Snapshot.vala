public class Objects.Snapshot : GLib.Object {
	public int id { get; set; default = 0; }
	public int game_id { get; set; default = 0; }
	public int is_automatic { get; set; default = 0; }
	public string date_added { get; set; default = new GLib.DateTime.now_local ().to_string (); }

	private string _path;
	public string path {
		get {
			_path = "%s/%i/%i".printf (RetroByte.utils.SNAPSHOTS_FOLDER, game_id, id);
			return _path;
		}

		set {
			_path = value;
		}
	}

	public void save_state (Retro.Core core, Retro.CoreView core_view) {
		RetroByte.utils.create_dir_with_parents ("/com.github.alainm23.retro-byte/snapshots/" + game_id.to_string ());
		RetroByte.utils.create_dir_with_parents ("/com.github.alainm23.retro-byte/snapshots/" + game_id.to_string () + "/" + id.to_string ());

		core.save_state (Path.build_filename (path, "snapshot"));

		core_view.get_pixbuf ().save (
			Path.build_filename (path, "screenshot"), "jpeg", "quality", "100"
		);

		if (core.get_memory_size (Retro.MemoryType.SAVE_RAM) > 0) {
			core.save_memory (Retro.MemoryType.SAVE_RAM, Path.build_filename (path, "save"));
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

	public string get_save_directory_path () {
		return Path.build_filename (path, "save-dir");
	}

	public void copy_save_dir_to (string dest) throws Error {
		var save_dir_file = File.new_for_path (get_save_directory_path ());
		var dest_file = File.new_for_path (dest);

		RetroByte.utils.copy_contents (save_dir_file, dest_file);
	}
}