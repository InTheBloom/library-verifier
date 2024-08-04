import std.json;
import std.typecons;

interface IConfig {
    void
        set_config_file_path
        (string path);

    Tuple!(bool, string)
        try_read_config
        ();

    string
        determine_used_language
        (string filename);

    string
        determine_file_type
        (string filename);
}

class Config : IConfig {
    this () {}

    /* implement */
}
