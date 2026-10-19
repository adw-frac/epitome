// Built by clang++: drives catch.cpp's functions (compiled by draconian).
#include <cstdio>
#include <stdexcept>

extern "C" int classify(int kind, int *dtors);
extern "C" void cleanup_only(int kind, int *dtors);
extern "C" void rethrows(int kind, int *seen);
extern "C" int nested(int kind, int *dtors);

void thrower(int kind) {
    switch (kind) {
    case 1: throw std::runtime_error("r");
    case 2: throw 7;
    case 3: throw 2.5;
    case 4: throw std::logic_error("l");
    }
}

int main() {
    int d = 0;
    for (int k = 0; k < 4; k++) printf("classify(%d) = %d\n", k, classify(k, &d));
    printf("destructors %d\n", d);
    d = 0;
    try {
        cleanup_only(2, &d);
    } catch (int v) {
        printf("cleanup_only threw %d, destructors %d\n", v, d);
    }
    int seen = 0;
    try {
        rethrows(1, &seen);
    } catch (const std::runtime_error &e) {
        printf("rethrown %s, seen %d\n", e.what(), seen);
    }
    d = 0;
    printf("nested(2) = %d, nested(4) = %d, nested(0) = %d, destructors %d\n", nested(2, &d), nested(4, &d),
           nested(0, &d), d);
}
