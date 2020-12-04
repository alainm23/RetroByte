public class Services.RetroCoreManager : GLib.Object {
    private bool searched;
    private Retro.CoreDescriptor[] core_descriptors;
    private HashTable<string, Retro.CoreDescriptor> core_descriptor_ids;
    
    public RetroCoreManager () {
		searched = false;
		core_descriptors = {};
		core_descriptor_ids = new HashTable<string, Retro.CoreDescriptor> (str_hash, str_equal);
    }
    
    public void search_modules () {
		var modules = new Retro.ModuleQuery (true);
		foreach (var core_descriptor in modules) {
			try {
				if (!core_descriptor.get_is_emulator ())
					continue;

				if (core_descriptor.get_module_file () == null)
					continue;

				core_descriptors += core_descriptor;
                core_descriptor_ids[core_descriptor.get_id ()] = core_descriptor;
			}
			catch (Error e) {
				debug (e.message);
			}
		}
	}

	public Retro.CoreDescriptor? get_core_for_id (string id) {
		if (!(id in core_descriptor_ids))
			return null;

		return core_descriptor_ids[id];
	}

	//  private Settings get_settings (RetroPlatform platform) {
	//  	var path = "/org/gnome/Games/platforms/%s/".printf (platform.get_id ());
	//  	return new Settings.with_path ("org.gnome.Games.platforms", path);
	//  }

	//  public void set_preferred_core (RetroPlatform platform, Retro.CoreDescriptor core_descriptor) {
	//  	get_settings (platform).set_string ("preferred-core", core_descriptor.get_id ());
	//  }

	//  public Retro.CoreDescriptor? get_preferred_core (RetroPlatform platform) {
	//  	if (!searched) {
	//  		searched = true;
	//  		search_modules ();
	//  	}

	//  	var preferred_core = get_settings (platform).get_string ("preferred-core");

	//  	var core_descriptor = core_descriptor_ids[preferred_core];
	//  	if (core_descriptor == null || !core_descriptor.has_platform (platform.get_id ())) {
	//  		var cores = get_cores_for_platform (platform);

	//  		if (cores.length > 0)
	//  			return get_cores_for_platform (platform)[0];

	//  		return null;
	//  	}

	//  	return core_descriptor;
	//  }

	//  public Retro.CoreDescriptor[] get_cores_for_platform (RetroPlatform platform) {
	//  	if (!searched) {
	//  		searched = true;
	//  		search_modules ();
	//  	}

	//  	var platform_id = platform.get_id ();
	//  	var mime_types = platform.get_mime_types ();

	//  	var result = new Array<Retro.CoreDescriptor> ();

	//  	var preferred_core = get_settings (platform).get_string ("preferred-core");

	//  	foreach (var core_descriptor in core_descriptors) {
	//  		try {
	//  			if (!core_descriptor.has_platform (platform_id))
	//  				continue;

	//  			if (!core_descriptor.get_platform_supports_mime_types (platform_id, mime_types))
	//  				continue;

	//  			// Insert preferred core at the start of the list
	//  			if (core_descriptor.get_id () == preferred_core)
	//  				result.prepend_val (core_descriptor);
	//  			else
	//  				result.append_val (core_descriptor);
	//  		}
	//  		catch (Error e) {
	//  			debug (e.message);
	//  		}
	//  	}

	//  	return result.data;
	//  }
}