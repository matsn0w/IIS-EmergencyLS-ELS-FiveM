# Usage of miscs as light sources

Additionally to extras, MISS-ELS has support for miscs as light sources. This enables the author of a vehicle to use up to 38 (12 extras + 26 miscs) light sources!

## Resource development

When you ship your misc enabled vehicle, make sure to include the MISS-ELS modkit in a (separate) `carcols.meta` file. Add the kit to your own file or include [this file](examples/carcols.xml) as `carcols.xml`. Read more about streaming these files [here](https://docs.fivem.net/docs/scripting-reference/resource-manifest/resource-manifest/#data_file).

Then, your vehicle should reference to `miss_els_modkit` in it's `carvariations.meta` entry. See [the example file](examples/carvariations.meta).

Now, you are free to use any of the 26 miscs on your vehicle model (YFT).

## Vehicle development

As a vehicle author, you simply add `misc_x` to your vehicle, just like you would do with an extra. You can use `misc_a` till `misc_z`.
