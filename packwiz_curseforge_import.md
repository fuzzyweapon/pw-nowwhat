## packwiz curseforge import

Import a curseforge modpack, from a download URL or a downloaded pack zip, or an installed metadata json file

```
packwiz curseforge import [modpack] [flags]
```

### Options

```
  -h, --help   help for import
```

### Options inherited from parent commands

```
      --cache string              The directory where packwiz will cache downloaded mods (default "/Users/fuzzyweapon/Library/Caches/packwiz/cache")
      --config string             The config file to use (default "/Users/fuzzyweapon/Library/Application Support/packwiz/.packwiz.toml")
      --meta-folder string        The folder in which new metadata files will be added, defaulting to a folder based on the category (mods, resourcepacks, etc; if the category is unknown the current directory is used)
      --meta-folder-base string   The base folder from which meta-folder will be resolved, defaulting to the current directory (so you can put all mods/etc in a subfolder while still using the default behaviour) (default ".")
      --pack-file string          The modpack metadata file to use (default "pack.toml")
  -y, --yes                       Accept all prompts with the default or "yes" option (non-interactive mode) - may pick unwanted options in search results
```

### SEE ALSO

* [packwiz curseforge](packwiz_curseforge.md)	 - Manage curseforge-based mods

