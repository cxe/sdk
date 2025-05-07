import { Type } from "../../Type";

export class JSON extends Type
{
    extensions: Record<string, string> = {
        json: "JSON",
        jsonld: "JSON-LD",
        geojson: "GeoJSON",
        topojson: "TopoJSON",
        har: "HTTP Archive",
        ipynb: "Jupyter Notebook",
        mcmeta: "Minecraft Metadata"
    };

    contentType = 'application/json';
}
