import std.concurrency;
import std.stdio;
import std.exception;
import std.datetime;
import std.typecons;

void dosomething (int x) {
    bool timeout = false;
    for (int i = 0; i < x; i++) {
        if (timeout) return;
        receive(
            (bool _) {
                if (_) timeout = true;
            },
        );
        writeln("Hello, World!");
    }

    ownerTid.send(tuple(1, 1));
}

void f () {
    auto worker = spawn(&dosomething, 10000000);
    const recieved = receiveTimeout(
        dur!"msecs"(1),
        (Tuple!(int, int) result) {
            writefln("result: %s", result);
        }
    );

    if (!recieved) {
        worker.send(true);
        writeln("Timed out.");
    }
}
