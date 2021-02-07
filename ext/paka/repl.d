module paka.repl;
import purr.ir.walk;
import purr.bytecode;
import purr.base;
import purr.ast;
import purr.dynamic;
import purr.parse;
import purr.vm;
import purr.srcloc;
import purr.inter;
import std.stdio;
import std.algorithm;
import std.string;
import std.functional;

Node replParse(Location arg)
{
    size_t ctx = enterCtx;
    scope (exit)
    {
        exitCtx;
    }
    Node node = arg.parse;
    Walker walker = new Walker;
    Function func = walker.walkProgram(node, ctx);
    Dynamic res = run(func, null, func.exportLocalsToBaseCallback);
    if (res.type != Dynamic.Type.nil)
    {
        writeln(res);
    }
    ctx.replRun;
    return null;
}

/// runs a repl for paka language
void replRun(size_t ctx)
{
    while (true)
    {
        Location code;
        write(">>> ");
        code.src = readln;
        code.src ~= ";";
        Node node = code.parse;
        Walker walker = new Walker;
        Function func = walker.walkProgram(node, ctx);
        Dynamic res = run(func, null, func.exportLocalsToBaseCallback);
        if (res.type != Dynamic.Type.nil) {
            writeln(res);
        }
    }
}