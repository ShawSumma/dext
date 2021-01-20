module purr.plugin.plugins;

import purr.plugin.plugin;
import purr.base;
import purr.walk;
import purr.parse;
import purr.ast;

Plugin[] plugins;

Pair[] pluginLib()
{
    Pair[] ret;
    foreach (plugin; plugins)
    {
        ret ~= plugin.libs;
    }
    return ret;
}

void pushPlugin(ref Node delegate(string code)[string] par, Node delegate(string code)[string] vals)
{
    foreach (key, value; vals)
    {
        par[key] = value;
    }
}

void pushPlugin(ref Node delegate(Node[])[string] tf, Node delegate(Node[])[string] vals)
{
    foreach (key, value; vals)
    {
        tf[key] = value;
    }
}

void addPlugin(Plugin plugin)
{
    plugins ~= plugin;
    pushPlugin(parsers, plugin.parsers);
    pushPlugin(transformers, plugin.transformers);
}

class Plugin
{
    Pair[] libs;
    Node delegate(string code)[string] parsers;
    Node delegate(Node[])[string] transformers;

    override string toString()
    {
        string ret;
        ret ~= "Plugin(syms: ";
        ret ~= libs.length.to!string;
        ret ~= ", langs: ";
        ret ~= parsers.length.to!string;
        ret ~= ", transformers: ";
        ret ~= transformers.length.to!string;
        ret ~= ")";
        return ret;
    }
}
