function SHPB_lithofile(GUIpath)


lithologies = [{["Igneous"        ]}
    {["Metamorphic"    ]}
    {["Sedimentary"    ]}
    {["Other"          ]}
    {["Unknown"        ]}
    {["Andesite"       ]}
    {["Anorthosite"    ]}
    {["Aplite"         ]}
    {["Basalt"         ]}
    {["Basanite"       ]}
    {["Dacite"         ]}
    {["Diabase"        ]}
    {["Diorite"        ]}
    {["Dunite"         ]}
    {["Foidolite"      ]}
    {["Gabbro"         ]}
    {["Granite"        ]}
    {["Granitoid"      ]}
    {["Granodiorite"   ]}
    {["Harzburgite"    ]}
    {["Ignimbrite"     ]}
    {["Kimberlite"     ]}
    {["Komatiite"      ]}
    {["Latite"         ]}
    {["Lherzolite"     ]}
    {["Monzonite"      ]}
    {["Norite"         ]}
    {["Obsidian"       ]}
    {["Pegmatite"      ]}
    {["Peridotite"     ]}
    {["Phonolite"      ]}
    {["Pumice"         ]}
    {["Rhyolite"       ]}
    {["Syenite"        ]}
    {["Tephrite"       ]}
    {["Tonalite"       ]}
    {["Trachyte"       ]}
    {["Tuff"           ]}
    {["Amphibolite"    ]}
    {["Blueschist"     ]}
    {["Bunte Breccia"  ]}
    {["Cataclasite"    ]}
    {["Eclogite"       ]}
    {["Gneiss"         ]}
    {["Granulite"      ]}
    {["Greenschist"    ]}
    {["Hornfels"       ]}
    {["Marble"         ]}
    {["Metabasite"     ]}
    {["Metapelite"     ]}
    {["Migmatite"      ]}
    {["Mylonite"       ]}
    {["Phyllite"       ]}
    {["Pseudotachylite"]}
    {["Quarzite"       ]}
    {["Schist"         ]}
    {["Slate"          ]}
    {["Skarn"          ]}
    {["Suevite"        ]}
    {["Tectonite"      ]}
    {["Arkose"         ]}
    {["BIF"            ]}
    {["Breccia"        ]}
    {["Chalk"          ]}
    {["Chert"          ]}
    {["Claystone"      ]}
    {["Coal"           ]}
    {["Conglomerate"   ]}
    {["Diamictite"     ]}
    {["Diatomite"      ]}
    {["Dolostone"      ]}
    {["Evaporite"      ]}
    {["Flint"          ]}
    {["Greywacke"      ]}
    {["Lignite"        ]}
    {["Limestone"      ]}
    {["Marl"           ]}
    {["Mudstone"       ]}
    {["Oolite"         ]}
    {["Sandstone"      ]}
    {["Shale"          ]}
    {["Siltstone"      ]}
    {["Travertine"     ]}
    {["Turbidite"      ]}
    {["Wackestone"     ]}];
save(fullfile(GUIpath,'resources','lithologies.mat'),'lithologies')