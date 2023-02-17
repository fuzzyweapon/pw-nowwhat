## packwiz

A command line tool for creating Minecraft modpacks

### Options

```
      --cache string              The directory where packwiz will cache downloaded mods (default "/Users/fuzzyweapon/Library/Caches/packwiz/cache")
      --config string             The config file to use (default "/Users/fuzzyweapon/Library/Application Support/packwiz/.packwiz.toml")
  -h, --help                      help for packwiz
      --meta-folder string        The folder in which new metadata files will be added, defaulting to a folder based on the category (mods, resourcepacks, etc; if the category is unknown the current directory is used)
      --meta-folder-base string   The base folder from which meta-folder will be resolved, defaulting to the current directory (so you can put all mods/etc in a subfolder while still using the default behaviour) (default ".")
      --pack-file string          The modpack metadata file to use (default "pack.toml")
  -y, --yes                       Accept all prompts with the default or "yes" option (non-interactive mode) - may pick unwanted options in search results
```

### SEE ALSO

* [packwiz completion](packwiz_completion.md)	 - Generate the autocompletion script for the specified shell
* [packwiz curseforge](packwiz_curseforge.md)	 - Manage curseforge-based mods
* [packwiz init](packwiz_init.md)	 - Initialise a packwiz modpack
* [packwiz list](packwiz_list.md)	 - List all the mods in the modpack
* [packwiz modrinth](packwiz_modrinth.md)	 - Manage modrinth-based mods
* [packwiz refresh](packwiz_refresh.md)	 - Refresh the index file
* [packwiz remove](packwiz_remove.md)	 - Remove an external file from the modpack; equivalent to manually removing the file and running packwiz refresh
* [packwiz serve](packwiz_serve.md)	 - Run a local development server
* [packwiz update](packwiz_update.md)	 - Update an external file (or all external files) in the modpack
* [packwiz url](packwiz_url.md)	 - Add external files from a direct download link, for sites that are not directly supported by packwiz
* [packwiz utils](packwiz_utils.md)	 - Utilities for managing packwiz itself

