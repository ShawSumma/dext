module quest.std.comparable;

import std.conv;
import std.stdio;
import purr.dynamic;
import quest.maker;
import quest.qscope;
import purr.error;

Dynamic cmpLt(Args args)
{
    return dynamic(args[0] < args[1]);
}

Dynamic cmpGt(Args args)
{
    return dynamic(args[0] > args[1]);
}

Dynamic cmpLte(Args args)
{
    return dynamic(args[0] <= args[1]);
}

Dynamic cmpGte(Args args)
{
    return dynamic(args[0] >= args[1]);
}
