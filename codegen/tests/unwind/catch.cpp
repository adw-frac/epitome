// Compiled by epitome: functions with landing pads, which catch C++
// exceptions thrown by `thrower` (main_catch.cpp), clean up, and rethrow.
#include <stdexcept>

extern void thrower(int kind);

struct Count {
    int *p;
    ~Count() { *p += 1; }
};

// Catches by type, and everything else; the destructor runs either way.
extern "C" int classify(int kind, int *dtors) {
    try {
        Count c{dtors};
        thrower(kind);
        return 0;
    } catch (const std::runtime_error &) {
        return 1;
    } catch (int v) {
        return 10 + v;
    } catch (...) {
        return 3;
    }
}

// Only cleans up: the exception goes on to the caller (`_Unwind_Resume`).
extern "C" void cleanup_only(int kind, int *dtors) {
    Count a{dtors};
    Count b{dtors};
    thrower(kind);
}

// Catches, counts, and rethrows.
extern "C" void rethrows(int kind, int *seen) {
    try {
        thrower(kind);
    } catch (...) {
        *seen += 1;
        throw;
    }
}

// A try within a try: the inner one catches ints only.
extern "C" int nested(int kind, int *dtors) {
    try {
        Count c{dtors};
        try {
            Count d{dtors};
            thrower(kind);
        } catch (int v) {
            return 100 + v;
        }
        return 0;
    } catch (const std::exception &e) {
        return 200;
    }
}
