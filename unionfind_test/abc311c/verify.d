import std;

void main () {
    int N = readln.chomp.to!int;
    int[] A = readln.split.to!(int[]);
    A[] -= 1;

    solve(N, A);
}

void solve (int N, int[] A) {
    auto UF = UnionFind!int(N);
    int[] ans;

    foreach (i; 0..N) {
        if (!UF.areInSameGroup(i, A[i])) {
            UF.unite(i, A[i]);
            continue;
        }

        int cur = i;
        do {
            ans ~= cur;
            cur = A[cur];
        } while (cur != i);
        break;
    }

    writeln(ans.length);
    foreach (i; 0..ans.length) {
        write(ans[i]+1, (i == ans.length-1 ? "\n" : " "));
    }
}

class UnionFind_Dictionary (T) {
    private:
        T[T] parent;
        int[T] size;

    T findRoot (T x) {
        if (x !in parent) {
            addElement(x);
            return x;
        }

        if (parent[x] == x) return x;
        return parent[x] = findRoot(parent[x]);
    }

    bool areInSameGroup (T x, T y) {
        return findRoot(x) == findRoot(y);
    }

    void unite (T x, T y) {
        addElement(x), addElement(y);
        T larger, smaller;
        if (GroupSize(x) <= GroupSize(y)) {
            larger = findRoot(y);
            smaller = findRoot(x);
        } else {
            larger = findRoot(x);
            smaller = findRoot(y);
        }

        if (larger == smaller) return;

        parent[smaller] = larger;
        size[larger] += size[smaller];
    }

    int countGroups () {
        int res = 0;
        foreach (key, val; parent) {
            if (key == val) res++;
        }
        return res;
    }

    bool addElement (T x) {
        if (x in parent) return false;
        parent[x] = x;
        size[x] = 1;
        return true;
    }

    int GroupSize (T x) {
        addElement(x);
        return size[x];
    }

    T[][] enumerateGroups (T x) {
        T[][T] mp;
        foreach (key, val; parent) {
            mp[val] ~= key;
        }

        T[][] res = new T[][](mp.length, 0);
        int idx = 0;
        foreach (val; mp) {
            res[idx] = val;
            idx++;
        }

        return res;
    }
}

class UnionFind_Array {
    private:
        int N;
        int[] parent;
        int[] size;

    this (int N)
    in {
        assert(0 <= N, "N must be positive integer.");
    }
    do {
        this.N = N;
        parent = new int[](N);
        size = new int[](N);
        foreach (i; 0..N) {
            parent[i] = i;
            size[i] = 1;
        }
    }

    int findRoot (int x) 
    in {
        assert(0 <= x && x < N);
    }
    do {
        if (parent[x] == x) return x;
        return parent[x] = findRoot(parent[x]);
    }

    bool areInSameGroup (int x, int y)
    in {
        assert(0 <= x && x < N);
        assert(0 <= y && y < N);
    }
    do {
        return findRoot(x) == findRoot(y);
    }

    void unite (int x, int y)
    in {
        assert(0 <= x && x < N);
        assert(0 <= y && y < N);
    }
    do {
        int larger, smaller;
        if (GroupSize(x) <= GroupSize(y)) {
            larger = findRoot(y);
            smaller = findRoot(x);
        } else {
            larger = findRoot(x);
            smaller = findRoot(y);
        }

        if (larger == smaller) return;

        parent[larger] = smaller;
        size[larger] += size[smaller];
    }

    int countGroups () {
        int res = 0;
        foreach (x, par; parent) {
            if (x == par) res++;
        }
        return res;
    }

    int GroupSize (int x)
    in {
        assert(0 <= x && x < N);
    }
    do {
        return size[x];
    }

    int[][] enumerateGroups (int x)
    in {
        assert(0 <= x && x < N);
    }
    do {
        int[][] mp = new int[][](N, 0);
        int resSize = 0;
        foreach (v, par; parent) {
            if (mp[par].length == 0) resSize++;
            mp[par] ~= cast(int) v;
        }

        int[][] res = new int[][](resSize);
        int idx = 0;
        foreach (m; mp) {
            if (m.length == 0) continue;
            res[idx] = m;
            idx++;
        }

        return res;
    }
}

/* ------------------------------ */
/*          Constructors          */
/* ------------------------------ */

/* Dictionary UF */
auto UnionFind (T) () {
    return new UnionFind_Dictionary!(T)();
}

import std.range.primitives : isInputRange;
auto UnionFind (T, E) (E range) if (isInputRange!(E) || is(T == S[], S) || is(T == S[n], S, size_t n)) {
    auto res = new UnionFind_Dictionary!(T)();
    foreach (elem; range) {
        res.addElement(elem);
    }

    return res;
}

/* Array UF */
auto UnionFind (T) (int N) if (is(T == int)) {
    return new UnionFind_Array(N);
}
