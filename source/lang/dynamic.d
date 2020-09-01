module lang.dynamic;

import std.algorithm;
import std.conv;
import std.format;
import std.functional;
import std.math;
import std.traits;
import std.typecons;
import std.stdio;
import core.memory;
import lang.bytecode;
import lang.vm;
import lang.data.rope;
import lang.data.array;
import lang.base;

public import lang.number : Number;

alias Args = Dynamic[];
alias Array = Dynamic[];
alias Table = Dynamic[Dynamic];

Dynamic dynamic(T...)(T a)
{
    return Dynamic(a);
}

struct Dynamic
{
    enum Type : ubyte
    {
        nil,
        log,
        num,
        str,
        arr,
        tab,
        fun,
        pro,
        end,
        pac,
        dat,
    }

    union Value
    {
        bool log;
        Number num;
        string* str;
        Array* arr;
        Table* tab;
        union Callable
        {
            Dynamic function(Args) fun;
            Function pro;
        }

        Callable fun;
    }

align(1):
    Type type = Type.nil;
    Value value = void;

    this(Type t)
    {
        type = t;
    }

    this(bool log)
    {
        value.log = log;
        type = Type.log;
    }

    this(Number num)
    {
        value.num = num;
        type = Type.num;
    }

    this(string str)
    {
        value.str = [str].ptr;
        type = Type.str;
    }

    this(Array arr)
    {
        value.arr = [arr].ptr;
        type = Type.arr;
    }

    this(Table tab)
    {
        value.tab = [tab].ptr;
        type = Type.tab;
    }

    this(string* str)
    {
        value.str = str;
        type = Type.str;
    }

    this(Array* arr)
    {
        value.arr = arr;
        type = Type.arr;
    }

    this(Table* tab)
    {
        value.tab = tab;
        type = Type.tab;
    }

    this(Dynamic function(Args) fun)
    {
        value.fun.fun = fun;
        type = Type.fun;
    }

    this(Function pro)
    {
        value.fun.pro = pro;
        type = Type.pro;
    }

    this(Dynamic other)
    {
        value = other.value;
        type = other.type;
    }

    static Dynamic nil()
    {
        Dynamic ret = dynamic(false);
        ret.value = Dynamic.Value.init;
        ret.type = Dynamic.Type.nil;
        return ret;
    }

    size_t toHash() const nothrow  // override size_t toHash() const nothrow @trusted
    {
        switch (type)
        {
        default:
            return hashOf(type) ^ hashOf(value);
        case Type.str:
            return hashOf(*value.str);
        case Type.arr:
            return hashOf(*value.arr);
        case Type.tab:
            return hashOf(*value.tab);
        }
    }

    string toString()
    {
        return this.strFormat;
    }

    int opCmp(Dynamic other)
    {
        switch (type)
        {
        default:
            assert(0);
        case Type.nil:
            return 0;
        case Type.log:
            if (value.log == other.log)
            {
                return 0;
            }
            if (value.log < other.log)
            {
                return -1;
            }
            return 1;
        case Type.num:
            if (value.num == other.num)
            {
                return 0;
            }
            if (value.num < other.num)
            {
                return -1;
            }
            return 1;
        case Type.str:
            if (*value.str == other.str)
            {
                return 0;
            }
            if (*value.str < other.str)
            {
                return -1;
            }
            return 1;
        }
    }

    bool opEquals(const Dynamic other) const
    {
        return isEqual(this, other);
    }

    Dynamic opBinary(string op)(Dynamic other)
    {
        if (type == Type.num && other.type == Type.num)
        {
            return dynamic(mixin("value.num" ~ op ~ "other.num"));
        }
        if (type == Type.str && other.type == Type.str)
        {
            static if (op == "~" || op == "+")
            {
                return dynamic(*value.str ~ other.str);
            }
        }
        throw new Exception("invalid types: " ~ type.to!string ~ ", " ~ other.type.to!string);
    }

    Dynamic opOpAssign(string op)(Dynamic other)
    {
        if (type == Type.num && other.type == Type.num)
        {
            mixin("value.num" ~ op ~ "=other.num;");
            return dynamic();
        }
        if (type == Type.str && other.type == Type.str)
        {
            static if (op == "~" || op == "+")
            {
                *value.str ~= other.str;
                return dynamic();
            }
        }
        throw new Exception("invalid types: " ~ type.to!string ~ ", " ~ other.type.to!string);
    }

    Dynamic opUnary(string op)()
    {
        return dynamic(mixin(op ~ "value.num"));
    }

    ref bool log()
    {
        if (type != Type.log)
        {
            throw new Exception("expected logical type");
        }
        return value.log;
    }

    ref Number num()
    {
        if (type != Type.num)
        {
            throw new Exception("expected number type");
        }
        return value.num;
    }

    ref string str()
    {
        if (type != Type.str)
        {
            throw new Exception("expected string type");
        }
        return *value.str;
    }

    string* strPtr()
    {
        if (type != Type.str)
        {
            throw new Exception("expected string type");
        }
        return value.str;
    }

    ref Array arr()
    {
        if (type != Type.arr && type != Type.dat)
        {
            throw new Exception("expected array type");
        }
        return *value.arr;
    }

    Array* arrPtr()
    {
        if (type != Type.arr && type != Type.dat)
        {
            throw new Exception("expected array type");
        }
        return value.arr;
    }

    ref Table tab()
    {
        if (type != Type.tab)
        {
            throw new Exception("expected table type");
        }
        return *value.tab;
    }

    Table* tabPtr()
    {
        if (type != Type.tab)
        {
            throw new Exception("expected table type");
        }
        return value.tab;
    }

    ref Value.Callable fun()
    {
        if (type != Type.fun && type != Type.pro)
        {
            throw new Exception("expected callable type");
        }
        return value.fun;
    }

}

private bool isEqual(Dynamic a, Dynamic b)
{
    if (b.type != a.type)
    {
        return false;
    }
    if (a.value == b.value)
    {
        return true;
    }
    switch (a.type)
    {
    default:
        assert(0);
    case Dynamic.Type.nil:
        return true;
    case Dynamic.Type.log:
        return a.value.log == b.value.log;
    case Dynamic.Type.num:
        return a.value.num == b.value.num;
    case Dynamic.Type.str:
        return *a.value.str == *b.value.str;
    case Dynamic.Type.arr:
        return *a.value.arr == *b.value.arr;
    case Dynamic.Type.tab:
        return *a.value.tab == *b.value.tab;
    case Dynamic.Type.fun:
        return a.value.fun.fun == b.value.fun.fun;
    case Dynamic.Type.pro:
        return a.value.fun.pro == b.value.fun.pro;
    }
}

private string strFormat(Dynamic dyn, Dynamic[] before = null)
{
    if (canFind(before, dyn))
    {
        return "...";
    }
    before ~= dyn;
    scope (exit)
    {
        before.length--;
    }
    switch (dyn.type)
    {
    default:
        return "???";
    case Dynamic.Type.nil:
        return "nil";
    case Dynamic.Type.log:
        return dyn.log.to!string;
    case Dynamic.Type.num:
        if (dyn.num % 1 == 0)
        {
            return to!string(cast(long) dyn.num);
        }
        return dyn.num.to!string;
    case Dynamic.Type.str:
        if (before.length == 0)
        {
            return dyn.str;
        }
        else
        {
            return '"' ~ dyn.str ~ '"';
        }
    case Dynamic.Type.arr:
        char[] ret;
        ret ~= "[";
        foreach (i, v; dyn.arr)
        {
            if (i != 0)
            {
                ret ~= ", ";
            }
            ret ~= strFormat(v, before);
        }
        ret ~= "]";
        return cast(string) ret;
    case Dynamic.Type.tab:
        char[] ret;
        ret ~= "{";
        size_t i;
        foreach (v; dyn.tab.byKeyValue)
        {
            if (i != 0)
            {
                ret ~= ", ";
            }
            ret ~= strFormat(v.key, before);
            ret ~= ": ";
            ret ~= strFormat(v.value, before);
            i++;
        }
        ret ~= "}";
        return cast(string) ret;
    case Dynamic.Type.fun:
        string* name = dyn in serialLookup;
        if (name is null)
        {
            return "<lambda>";
        }
        return *name;
    case Dynamic.Type.pro:
        return dyn.fun.pro.to!string;
    }
}
