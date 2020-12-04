public class Objects.Snapshot : Object {
	public string path { get; construct; }
	public string platform { get; construct; }
	public string core { get; construct; }

	// Automatic means whether the snapshot was created automatically when
	// quitting/loading the game or manually by the user using the Save button
	public bool is_automatic { get; set; }
	public string name { get; set; }
	public DateTime? creation_date { get; set; }
	public double screenshot_aspect_ratio { get; set; }

	//  public static Snapshot load (string platform, string core_id, string path) {
	//  	var snapshot = Object.new (typeof (Objects.Snapshot),
	//  	                            "path", path,
	//  	                            "platform", platform,
	//  	                            "core", core_id,
	//  	                            null) as Objects.Snapshot;

	//  	snapshot.load_keyfile ();
	//  	return snapshot;
	//  }

	//  private void load_keyfile () {
	//  	var metadata_file_path = Path.build_filename (path, "metadata");
	//  	var metadata_file = File.new_for_path (metadata_file_path);

	//  	if (!metadata_file.query_exists ())
	//  		return;

	//  	var keyfile = new KeyFile ();

	//  	try {
	//  		keyfile.load_from_file (metadata_file_path, KeyFileFlags.NONE);
	//  		load_metadata (keyfile);
	//  	}
	//  	catch (Error e) {
	//  		critical ("Failed to load metadata for snapshot at %s: %s", path, e.message);
	//  	}
	//  }

	//  public string get_snapshot_path () {
	//  	return Path.build_filename (path, "snapshot");
	//  }

	//  public string get_save_ram_path () {
	//  	return Path.build_filename (path, "save");
	//  }

	//  public string get_screenshot_path () {
	//  	return Path.build_filename (path, "screenshot");
	//  }

	//  public string get_save_directory_path () {
	//  	return Path.build_filename (path, "save-dir");
	//  }

	//  public bool has_media_data () {
	//  	var media_path = Path.build_filename (path, "media");

	//  	return FileUtils.test (media_path, FileTest.EXISTS);
	//  }

	//  // Currently all games only have a number as media_data, so this method
	//  // returns an int, but in the future it might return an abstract MediaData
	//  public int get_media_data () throws Error {
	//  	var media_path = Path.build_filename (path, "media");

	//  	if (!FileUtils.test (media_path, FileTest.EXISTS))
	//  		throw new FileError.ACCES ("Snapshot at %s does not contain media file", path);

	//  	string contents;
	//  	FileUtils.get_contents (media_path, out contents);

	//  	int media_number = int.parse (contents);

	//  	return media_number;
	//  }

	//  public void set_media_data (MediaSet media_set) throws Error {
	//  	var media_path = Path.build_filename (path, "media");
	//  	var contents = media_set.selected_media_number.to_string ();

	//  	FileUtils.set_contents (media_path, contents, contents.length);
	//  }

	//  protected virtual void load_metadata (KeyFile keyfile) throws KeyFileError {
	//  	is_automatic = keyfile.get_boolean ("Metadata", "Automatic");

	//  	if (is_automatic)
	//  		name = null;
	//  	else
	//  		name = keyfile.get_string ("Metadata", "Name");

	//  	var creation_date_str = keyfile.get_string ("Metadata", "Creation Date");
	//  	creation_date = new DateTime.from_iso8601 (creation_date_str, new TimeZone.local ());

	//  	// Migrated snapshots aren't going to have this
	//  	if (keyfile.has_group ("Screenshot"))
	//  		screenshot_aspect_ratio = keyfile.get_double ("Screenshot", "Aspect Ratio");
	//  	else
	//  		screenshot_aspect_ratio = 0;
	//  }

	//  protected virtual void save_metadata (KeyFile keyfile) {
	//  	keyfile.set_boolean ("Metadata", "Automatic", is_automatic);
	//  	if (name != null)
	//  		keyfile.set_string ("Metadata", "Name", name);
	//  	keyfile.set_string ("Metadata", "Creation Date", creation_date.to_string ());

	//  	// FIXME: This is unused
	//  	keyfile.set_string ("Metadata", "Platform", platform.get_uid_prefix ());
	//  	keyfile.set_string ("Metadata", "Core", core);

	//  	keyfile.set_double ("Screenshot", "Aspect Ratio", screenshot_aspect_ratio);
	//  }

	//  public void write_metadata () throws Error {
	//  	var metadata_file_path = Path.build_filename (path, "metadata");
	//  	var metadata_file = File.new_for_path (metadata_file_path);
	//  	var metadata = new KeyFile ();

	//  	if (metadata_file.query_exists ())
	//  		metadata_file.@delete ();

	//  	save_metadata (metadata);

	//  	metadata.save_to_file (metadata_file_path);
	//  }

	//  public void delete_from_disk () {
	//  	var snapshot_dir = File.new_for_path (path);

	//  	// Treat errors locally in this method because there isn't much that
	//  	// can go wrong with deleting files
	//  	try {
	//  		FileOperations.delete_files (snapshot_dir, {});
	//  	}
	//  	catch (Error e) {
	//  		warning ("Failed to delete snapshot at %s: %s", path, e.message);
	//  	}
	//  }

	//  public static Snapshot create_empty (Game game, string core_id, string path) throws Error {
	//  	var random = Random.next_int ();
	//  	var tmp_path = @"$(path)_$random";

	//  	var dir = File.new_for_path (tmp_path);
	//  	dir.make_directory ();

	//  	var save_dir = dir.get_child ("save-dir");
	//  	save_dir.make_directory ();

	//  	return Snapshot.load (game.platform, core_id, tmp_path);
	//  }

	//  public Snapshot move_to (string dest_path) throws Error {
	//  	var current_dir = File.new_for_path (path);
	//  	var dest_dir = File.new_for_path (dest_path);

	//  	var dest = dest_path;
	//  	while (dest_dir.query_exists ()) {
	//  		dest += "_";
	//  		dest_dir = File.new_for_path (dest);
	//  	}

	//  	current_dir.move (dest_dir, FileCopyFlags.ALL_METADATA);

	//  	return Snapshot.load (platform, core, dest);
	//  }

	//  public void copy_save_dir_to (string dest) throws Error {
	//  	var save_dir_file = File.new_for_path (get_save_directory_path ());
	//  	var dest_file = File.new_for_path (dest);

	//  	FileOperations.copy_contents (save_dir_file, dest_file);
	//  }

	//  public static int compare (Snapshot s1, Snapshot s2) {
	//  	if (s1.path < s2.path)
	//  		return 1;

	//  	if (s1.path == s2.path)
	//  		return 0;

	//  	// s1.path > s2.path
	//  	return -1;
	//  }
}