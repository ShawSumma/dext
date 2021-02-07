module paka.base;

import purr.base;
import purr.dynamic;
import purr.error;
import paka.lib.io;
import paka.lib.sys;
import paka.lib.str;
import paka.lib.arr;
import paka.lib.tab;
import paka.lib.enforce;

/// string concatenate for format strings and unicode literals
Dynamic strconcat(Args args)
{
    string ret;
    foreach (arg; args)
    {
        ret ~= arg.str;
    }
    return ret.dynamic;
}

/// internal map function
Dynamic syslibubothmap(Args args)
{
    Array ret;
    if (args[1].arr.length != args[2].arr.length)
    {
        throw new BoundsException("bad lengths in dotmap");
    }
    foreach (i; 0 .. args[1].arr.length)
    {
        ret ~= args[0]([args[1].arr[i], args[2].arr[i]]);
    }
    return dynamic(ret);
}

/// internal map function
Dynamic syslibulhsmap(Args args)
{
    Array ret;
    foreach (i; args[1].arr)
    {
        ret ~= args[0]([i, args[2]]);
    }
    return dynamic(ret);
}

/// internal map function
Dynamic sysliburhsmap(Args args)
{
    Array ret;
    foreach (i; args[2].arr)
    {
        ret ~= args[0]([args[1], i]);
    }
    return dynamic(ret);
}

/// internal map function
Dynamic syslibupremap(Args args)
{
    Array ret;
    foreach (i; args[1].arr)
    {
        ret ~= args[0]([i]);
    }
    return dynamic(ret);
}

Pair[] pakaBaseLibs()
{
    Pair[] ret;
    ret ~= Pair("_both_map", &syslibubothmap);
    ret ~= Pair("_lhs_map", &syslibulhsmap);
    ret ~= Pair("_rhs_map", &sysliburhsmap);
    ret ~= Pair("_pre_map", &syslibupremap);
    ret ~= Pair("_str_concat", &strconcat);
    ret ~= Pair("_paka_enforce", &pakaenforce);
    ret ~= Pair("_paka_enforce_call", &enforcecall);
    ret ~= Pair("_paka_enforce_special_call", &enforcespeicalcall);
    ret ~= Pair("_paka_enforce_lit", &enforcelit);
    ret ~= Pair("_paka_enforce_var", &enforcevar);
    ret.addLib("str", libstr);
    ret.addLib("arr", libarr);
    ret.addLib("tab", libtab);
    ret.addLib("io", libio);
    ret.addLib("sys", libsys);
    return ret;
}