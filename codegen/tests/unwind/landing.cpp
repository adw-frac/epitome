// Landing pads without headers: catches by type and of everything,
// cleanups, rethrows, nested trys, and a throw of a class.
void g(int);
int h(int);
struct D { int *p; ~D() { ++*p; } };
struct E { int code; };
int count;

int by_type(int x) {
    try { D d{&count}; g(x); } catch (int e) { return e; } catch (E &e) { return e.code; } catch (...) { return -1; }
    return 0;
}
int rethrows(int x) {
    try {
        try { g(x); } catch (int e) { if (e > 5) throw; return e * 2; }
    } catch (int e) { return e + 100; }
    return 0;
}
int cleanup_only(int x) { D a{&count}; D b{&count}; return h(x) + h(x + 1); }
void throws(int x) { if (x) throw E{x}; g(x); }
