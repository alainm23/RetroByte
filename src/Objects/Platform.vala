public class Objects.Platform : Object {
	private string name;
	private string id;
	private string[] mime_types;
	private string prefix;

	public Platform (string id, string name, string[] mime_types, string prefix) {
		this.id = id;
		this.name = name;
		this.mime_types = mime_types;
		this.prefix = prefix;
	}

	public string get_id () {
		return id;
	}

	public string get_name () {
		return name;
	}

	public string get_uid_prefix () {
		return prefix;
	}

	public string[] get_mime_types () {
		return mime_types;
    }
    
	public virtual Type get_snapshot_type () {
		return typeof (Objects.Snapshot);
	}
}